#!/usr/env node
/*
   updater.js - NodeJS version of the updater
*/
import {execFile} from 'child_process'
import {Readable} from 'stream'
import fs from 'fs'
import crypto from 'crypto'
import {timingSafeEqual} from 'crypto'
import path from 'path'

const MAX_CONTENT_LENGTH = 100 * 1024 * 1024 // 100 MB
const DOWNLOAD_TIMEOUT = 10 * 60 * 1000 // 10 minutes
const SCRIPT_TIMEOUT = 5 * 60 * 1000 // 5 minutes
const MAX_PROPERTIES = 50
const FILE_MODE = 0o600

function usage() {
    console.log(
        `usage: update [options] [key=value,...]
            "--cmd script        # Script to invoke to apply the update
            "--device ID         # Unique device ID
            "--file image/path   # Path to save the downloaded update
            "--host host.domain  # Device cloud endpoint from the Builder cloud edit panel
            "--product ProductID # ProductID from the Buidler token list
            "--token TokenID     # CloudAPI access token from the Builder token list
            "--version SemVer    # Current device firmware version
            "--verbose           # Trace execution
            "key:value,...       # Device-specific properties for the distribution policy`
    )
    process.exit(2)
}

let file = 'update.bin'
const properties = {}
let cmd, device, host, product, token, version
let verbose = false

async function main() {
    parseArgs()

    /*
        Request update
     */
    let body = Object.assign(
        {
            id: device,
            product: product,
            version: version,
        },
        properties
    )
    if (verbose) {
        console.log('Check for updates\n', JSON.stringify(body, null, 2), '\n')
    }
    let response = await fetch(`${host}/tok/provision/update`, {
        method: 'POST',
        headers: {
            Authorization: token,
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
    })
    if (!response.ok) {
        console.error(response)
        throw new Error('Cannot fetch update')
    }
    let data = await response.text()
    if (verbose) {
        console.log('Update response\n', data, '\n')
    }
    if (!data || data.trim() === '') {
        console.log('No update available')
        return
    } else {
        try {
            data = JSON.parse(data)
        } catch (error) {
            console.error('Invalid JSON response', data)
            throw new Error('Invalid JSON response')
        }
        /*
            Update available if "url" defined
        */
        if (data.url) {
            //  Validate response completeness
            if (!data.checksum || !data.update || !data.version) {
                throw new Error('Incomplete update response')
            }

            //  Validate HTTPS
            if (!data.url.startsWith('https://')) {
                throw new Error('Insecure download URL (HTTPS required)')
            }

            console.log(`Update ${data.version} available`)

            //  Download update image to "path"
            try {
                await download(data.url, file)
            } catch (error) {
                console.error('Download failed:', error.message)
                throw new Error('Failed to download update')
            }

            //  Verify checksum
            let sum
            try {
                sum = await getChecksum(file)
            } catch (error) {
                console.error('Checksum calculation failed:', error.message)
                throw new Error('Failed to calculate checksum')
            }
            //  Use timing-safe comparison
            if (sum.length !== data.checksum.length || !timingSafeEqual(Buffer.from(sum), Buffer.from(data.checksum))) {
                console.error(`Checksum does not match\n${sum} vs\n${data.checksum}`)
                throw new Error('Update checksum does not match')
            }
            if (cmd) {
                console.log(`Checksum matches, apply update`)
                let success = await applyUpdate(cmd, file)
                //  Post update report
                let upbody = {
                    success,
                    id: device,
                    update: data.update,
                }
                if (verbose) {
                    console.log(`Post update results ${success ? 'success' : 'failed'}`)
                }
                try {
                    let reportResponse = await fetch(`${host}/tok/provision/updateReport`, {
                        method: 'POST',
                        headers: {
                            Authorization: token,
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(upbody),
                    })
                    if (!reportResponse.ok) {
                        console.error('Cannot post update-report')
                    }
                } catch (error) {
                    console.error('Failed to post update report:', error.message)
                }
            }
        }
    }
}

/*
    Apply the update by running the external "cmd" script
 */
async function applyUpdate(cmd, path) {
    //  Verify script exists and is executable
    try {
        fs.accessSync(cmd, fs.constants.X_OK)
    } catch (error) {
        console.error(`Script ${cmd} is not executable or does not exist`)
        return false
    }

    if (verbose) {
        console.log(`Apply update ${path} using ${cmd}`)
    }
    let status = await new Promise((resolve, reject) => {
        execFile(cmd, [path], {timeout: SCRIPT_TIMEOUT}, (error) => {
            if (error) {
                console.error(`Update failed`, error.message)
                resolve(false)
            } else {
                console.log(`Update applied successfully`)
                resolve(true)
            }
        })
    })
    return status
}

function parseArgs() {
    let args = process.argv.slice(2)
    let i = 0
    for (; i < args.length; i++) {
        let arg = args[i]
        if (arg[0] != '-') break
        if (arg == '--cmd') {
            cmd = args[++i]
        } else if (arg == '--device') {
            device = args[++i]
        } else if (arg == '--file') {
            file = args[++i]
            if (path.isAbsolute(file) || file.includes('..')) {
                console.error('Invalid file path. Only relative paths in current directory are allowed.')
                usage()
            }
        } else if (arg == '--host') {
            host = args[++i]
        } else if (arg == '--product') {
            product = args[++i]
        } else if (arg == '--token') {
            token = args[++i]
        } else if (arg == '--version') {
            version = args[++i]
        } else if (arg == '--verbose' || arg == '-v') {
            verbose = true
        } else {
            usage()
        }
    }
    let propCount = 0
    for (; i < args.length && propCount < MAX_PROPERTIES; i++, propCount++) {
        let [key, value] = args[i].split('=')
        if (!key || !value) {
            console.error('Invalid property format. Expected key=value')
            usage()
        }
        properties[key.trim()] = value.trim()
    }
    if (i < args.length) {
        console.error(`Too many properties specified (max: ${MAX_PROPERTIES})`)
        usage()
    }
    if (!file || !host || !product || !token || !device || !version) {
        usage()
    }
}

/*
    Stream download the file from the given url to the path
 */
async function download(url, path) {
    let res = await fetch(url)
    if (!res.ok) {
        throw new Error(`Failed to fetch ${url}: ${res.statusText}`)
    }

    //  Validate Content-Length
    const contentLengthHeader = res.headers.get('content-length')
    if (!contentLengthHeader) {
        throw new Error('Missing Content-Length')
    }
    const contentLength = parseInt(contentLengthHeader, 10)
    if (isNaN(contentLength) || !isFinite(contentLength) || contentLength < 0 || contentLength > MAX_CONTENT_LENGTH) {
        throw new Error('Invalid Content-Length')
    }

    if (verbose) {
        console.log(`Downloading update to ${path}`)
    }

    //  Use 'wx' flag for exclusive creation - will fail if file exists
    //  If it fails, try to remove and retry once
    let stream
    try {
        stream = fs.createWriteStream(path, {flags: 'wx', mode: FILE_MODE})
    } catch (error) {
        if (error.code === 'EEXIST') {
            fs.unlinkSync(path)
            stream = fs.createWriteStream(path, {flags: 'wx', mode: FILE_MODE})
        } else {
            throw error
        }
    }
    Readable.fromWeb(res.body).pipe(stream)

    return await new Promise((resolve, reject) => {
        //  Add timeout
        const timeout = setTimeout(() => {
            stream.destroy()
            reject(new Error('Download timeout'))
        }, DOWNLOAD_TIMEOUT)

        stream.on('error', (error) => {
            clearTimeout(timeout)
            stream.destroy()
            //  Remove partial file
            try {
                fs.unlinkSync(path)
            } catch (e) {
                // Ignore cleanup errors
            }
            reject(error)
        })
        stream.on('finish', () => {
            clearTimeout(timeout)
            //  Verify it's a regular file
            try {
                const stats = fs.statSync(path)
                if (!stats.isFile()) {
                    fs.unlinkSync(path)
                    reject(new Error('Refusing to write to non-regular file'))
                } else {
                    resolve()
                }
            } catch (error) {
                reject(error)
            }
        })
    })
}

/*
    Get the checksum of the given file
 */
async function getChecksum(path) {
    return new Promise((resolve, reject) => {
        const hash = crypto.createHash('sha256')
        const stream = fs.createReadStream(path)
        stream.on('error', (err) => {
            reject(err)
        })
        stream.on('data', (chunk) => {
            hash.update(chunk)
        })
        stream.on('end', () => {
            const sha256 = hash.digest('hex')
            resolve(sha256)
        })
    })
}

main()
