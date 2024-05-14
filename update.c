/*
    update.c - Check for software updates
 */

/********************************** Includes **********************************/
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

#include "update.h"

/********************************** Locals ************************************/

#define SERVER_PORT 443
#define BUFFER_SIZE 4096
#define IMAGE_PATH "/tmp/update.bin"

typedef struct Up {
    SSL_CTX *ctx;
    SSL *ssl;
    int sockfd;
} Up;


/********************************** Forwards **********************************/

static int applyUpdate(cchar *path, cchar *script);
static int download(Up *up, cchar *path, char *checksum);
static int getImageChecksum(cchar *path, char sum[EVP_MAX_MD_SIZE]);
static int initUp(Up *up);
static char *json(cchar *json, cchar *key);
static int readResponse(Up *up, char **url, char **checksum);
static int sendRequest(Up *up, char *method, char *url, char *headers, char *body);
static void termUp(Up *up);

/************************************ Code ************************************/
/*
    Update parameters:
    host - Device Cloud endpoint from the Builder Cloud Edit panel
    product - ProductID token from the Builder token list
    token - CloudAPI token from the Builder token list
    device - Unique device ID 
    version - device firmware version 
    properties - Additional device properties [key=value, ...]
    path - Path name to save the downloaded update
    script - Script path to invoke to apply the update
 */
int update(cchar *host, cchar *product, cchar *token, cchar *device, cchar *version, cchar *properties, cchar *path, cchar *script)
{
    Up up;
    char body[BUFFER_SIZE], request[BUFFER_SIZE], endpoint[256], headers[256];
    char *checksum, *url;

    if (!path) {
        path = IMAGE_PATH;
    }

    /*
        Issue update request to determine if there is an update
    */
    snprintf(body, sizeof(body),
        "{\"id\":\"%s\",\"product\":\"%s\",\"version\":\"%s\",%s}", device, product, version, properties);

    snprintf(endpoint, sizeof(endpoint), "%s/tok/provision/update", host);
    snprintf(headers, sizeof(headers), "Content-Type: application/json\r\nAuthorization: %s\r\n", token);
    if (sendRequest(&up, "POST", endpoint, headers, body) < 0) {
        termUp(&up);
        return -1;
    }
    if (readResponse(&up, &url, &checksum) < 0) {
        termUp(&up);
        return -1;
    }
    termUp(&up);

    if (url) {
        snprintf(headers, sizeof(headers), "Accept: */*\r\n");
        if (sendRequest(&up, "GET", url, headers, NULL) < 0) {
            termUp(&up);
            return -1;
        }
        if (download(&up, path, checksum) < 0) {
            termUp(&up);
            return -1;
        }
        free(checksum);
        free(url);
        termUp(&up);

        if (script && applyUpdate(path, script) < 0) {
            return -1;
        }
    } else {
        printf("No update required\n");
    }
    return 0;
}

static int sendRequest(Up *up, char *method, char *url, char *headers, char *body) 
{
    struct sockaddr_in server_addr;
    struct hostent *server;
    char request[BUFFER_SIZE], uri[BUFFER_SIZE];
    char *host, *path;

    initUp(up);

    strncpy(uri, url, sizeof(uri));
    if ((host = strstr(uri, "https://")) != NULL) {
        host += 8;
    } else {
        host = uri;
    }
    if ((path = strchr(host, '/')) != NULL) {
        *path++ = '\0';
    } else {
        path = "";
    }
    up->sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (up->sockfd < 0) {
        perror("ERROR opening socket");
        return -1;
    }
    server = gethostbyname(host);
    if (server == NULL) {
        fprintf(stderr, "ERROR, no such host\n");
        return -1;
    }
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    memcpy(&server_addr.sin_addr.s_addr, server->h_addr, server->h_length);
    server_addr.sin_port = htons(SERVER_PORT);

    if (connect(up->sockfd, (struct sockaddr*) &server_addr, sizeof(server_addr)) < 0) {
        perror("ERROR connecting");
        return -1;
    }
    SSL_set_fd(up->ssl, up->sockfd);
    if (SSL_connect(up->ssl) != 1) {
        ERR_print_errors_fp(stderr);
        return -1;
    }
    /*
        Format the request and calculate the body content length
     */
    snprintf(request, sizeof(request), 
        "%s /%s HTTP/1.1\r\n" \
        "Host: %s\r\n" \
        "Content-Length: %d\r\n" \
        "%s\r\n" \
        "%s",
        method, path, host, body ? (int) strlen(body) : 0, headers, body ? body : "");

    /*
        Write the request and wait for a response
     */
    if (SSL_write(up->ssl, request, strlen(request)) <= 0) {
        ERR_print_errors_fp(stderr);
        return -1;
    }
    return 0;
}

static int readResponse(Up *up, char **url, char **checksum) 
{
    char *body, response[BUFFER_SIZE];

    memset(response, 0, BUFFER_SIZE);
    if (SSL_read(up->ssl, response, BUFFER_SIZE - 1) < 0) {
        ERR_print_errors_fp(stderr);
        return -1;
    }
    if ((body = strstr(response, "\r\n")) == NULL) {
        fprintf(stderr, "ERROR, bad response\n%s\n", response);
        return -1;
    }
    body += 2;
    /*
        Response is a JSON buffer with properties: {checksum, version, url}
     */
    *url = json(body, "url");
    *checksum = json(body, "checksum");
    if (url && !checksum) {
        fprintf(stderr, "Bad update response: %s", response);
        return -1;
    }
    return 0;
}

static int download(Up *up, cchar *path, char *checksum) 
{
    char buf[BUFFER_SIZE], sum[EVP_MAX_MD_SIZE * 2 + 1], *body;
    int bytes, fd, seenHeaders;

    if ((fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0600)) < 0) {
        fprintf(stderr, "Cannot open image temp file");
        return -1;
    }
    seenHeaders = 0;
    while ((bytes = SSL_read(up->ssl, buf, sizeof(buf))) > 0) {
        buf[bytes] = '\0';
        if (!seenHeaders) {
            if ((body = strnstr(buf, "\r\n\r\n", sizeof(buf))) == NULL) {
                fprintf(stderr, "ERROR, bad response\n");
                return -1;
            }
            seenHeaders = 1;
            body += 4;
            bytes -= body - buf;
        } else {
            body = buf;
        }
        if (seenHeaders) {
            if (write(fd, body, bytes) != bytes) {
                fprintf(stderr, "Cannot save response");
                return -1;
            }
        }
    }
    close(fd);
    getImageChecksum(path, sum);
    if (strcmp(sum, checksum) != 0) {
        fprintf(stderr, "Checksum does not match\n%s vs\n%s\n", sum, checksum);
        return -1;
    }
    return 0;
}

/*
    Apply the update by invoking the "scripts.update" script
    This may exit or reboot if instructed by the update script
 */
static int applyUpdate(cchar *path, cchar *script)
{
    char  command[BUFFER_SIZE];
    int   status;

    snprintf(command, sizeof(command), "%s \"%s\"", script, path);
    status = system(command);
    if (status != 0) {
        fprintf(stderr, "Update command failed: %d", status);
    } else {
        printf("Update successfully applied\n");
    }
    return status;
}

static int initUp(Up *up)
{
    const SSL_METHOD *method;

#if INIT_OPENSSL
    init_openssl();
#endif
    memset(up, 0, sizeof(Up));
    method = TLS_client_method();
    up->ctx = SSL_CTX_new(method);
    if (!up->ctx) {
        perror("Unable to create SSL context");
        ERR_print_errors_fp(stderr);
        return -1;
    }
    up->ssl = SSL_new(up->ctx);
    return 0;
}

static void termUp(Up *up) 
{
    SSL_free(up->ssl);
    SSL_CTX_free(up->ctx);
#if INIT_OPENSSL
    cleanup_openssl();
#endif
    close(up->sockfd);
}

static char *json(cchar *json, cchar *key) 
{
    char *end, *keyPos, *start;
    int quoted;

    keyPos = strstr(json, key);
    if (keyPos) {
        keyPos += strlen(key) + 2;  // assuming format is "key":<space>
        quoted = (*keyPos == '"') ? 1 : 0;
        start = quoted ? keyPos + 1 : keyPos;
        end = start;
        while (*end && ((quoted && *end != '"') || (!quoted && *end != ',' && *end != '}'))) {
            end++;
        }
        int size = end - start;
        char *value = (char*) malloc(size + 1);
        if (value) {
            strncpy(value, start, size);
            value[size] = '\0';
            return value;
        }
    }
    return NULL;
}

static int getImageChecksum(cchar *path, char *sum) 
{
    FILE *file;
    EVP_MD_CTX *mdctx;
    unsigned char buf[BUFFER_SIZE], hash[EVP_MAX_MD_SIZE];
    unsigned int len;
    size_t bytes;
    
    file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "Cannot open %s\n", path);
        return -1;
    }
    mdctx = EVP_MD_CTX_new();
    if (!mdctx) {
        fprintf(stderr, "Failed to create EVP_MD_CTX");
        fclose(file);
        return -1;
    }
    if (EVP_DigestInit_ex(mdctx, EVP_sha256(), NULL) != 1) {
        fprintf(stderr, "DigestInit error\n");
        EVP_MD_CTX_free(mdctx);
        fclose(file);
        return -1;
    }
    while ((bytes = fread(buf, 1, sizeof(buf), file)) > 0) {
        if (EVP_DigestUpdate(mdctx, buf, bytes) != 1) {
            fprintf(stderr, "DigestUpdate error\n");
            EVP_MD_CTX_free(mdctx);
            fclose(file);
            return -1;
        }
    }
    if (EVP_DigestFinal_ex(mdctx, hash, &len) != 1) {
        fprintf(stderr, "DigestFinal error\n");
        EVP_MD_CTX_free(mdctx);
        fclose(file);
        return -1;
    }
    EVP_MD_CTX_free(mdctx);
    fclose(file);

    for (int i = 0; i < len; i++) {
        sprintf(&sum[i * 2], "%02x", hash[i]);
    }
    return 0;
}
