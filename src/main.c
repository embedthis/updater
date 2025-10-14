/*
    main.c - Command-line interface for the EmbedThis Updater

    This is the main entry point for the updater command-line utility. It parses command-line
    arguments and invokes the update() library function to perform OTA updates.

    Usage:
        update --host Domain --token Token --product ProductID --device DeviceID --version 1.2.3 \
            [--file path] [--cmd script] [--verbose] [key=value ...]

    The utility supports both required parameters (host, token, product, device, version) and
    optional device-specific properties for update policy matching.

    Copyright (c) EmbedThis Software. All Rights Reserved.
 */

/********************************** Includes **********************************/

#include "updater.h"

/********************************** Locals ************************************/

#define IMAGE_PATH  "update.bin" // Default path for downloaded update image
#define SERVER_PORT 443          // HTTPS port (currently unused in main.c)
#define BUFFER_SIZE 4096         // Maximum size for properties JSON buffer

// Command-line argument values (pointers into argv)
static cchar *cmd;               // Path to script that applies the update
static cchar *device;            // Unique device identifier
static cchar *file;              // Path where update image will be saved
static cchar *host;              // Builder cloud endpoint URL
static cchar *product;           // Product ID from Builder token list
static cchar *token;             // CloudAPI access token for authentication
static cchar *version;           // Current device firmware version

// Dynamically allocated JSON string of device properties
static char *properties;

// Verbose output flag
static int verbose = 0;

/********************************** Forwards **********************************/

static int parseArgs(int argc, char **argv);

/************************************ Code ************************************/

/**
    Display usage information and exit

    Prints the command-line syntax and available options to stderr, then exits
    with status code 2 (conventional for usage errors).

    @stability Stable
 */
static int usage(void)
{
    fprintf(stderr, "usage: update [options] [key=value,...]\n"
            "--cmd script        # Script to invoke to apply the update\n"
            "--device ID         # Unique device ID\n"
            "--file image/path   # Path to save the downloaded update\n"
            "--host host.domain  # Device cloud endpoint from the Builder cloud edit panel\n"
            "--product ProductID # ProductID from the Builder token list\n"
            "--token TokenID     # CloudAPI access token from the Builder token list\n"
            "--version SemVer    # Current device firmware version\n"
            "--verbose           # Trace execution\n"
            "key=value,...       # Device-specific properties for the distribution policy\n");
    exit(2);
}

/**
    Main entry point for the updater command-line utility

    Parses command-line arguments, validates required parameters, and invokes the
    update() library function to perform the OTA update workflow.

    @param argc Number of command-line arguments
    @param argv Array of command-line argument strings
    @return 0 on success, -1 on error (or exits via usage())

    @stability Stable
 */
int main(int argc, char **argv)
{
    int rc;

    // Parse command-line arguments into global variables
    if (parseArgs(argc, argv) < 0) {
        return -1;
    }

    // Validate that all required parameters are present
    if (!host || !product || !token || !device || !version) {
        usage();
    }

    // Perform the OTA update
    rc = update(host, product, token, device, version, properties, file, cmd, verbose);

    // Clean up dynamically allocated properties string
    free(properties);
    return rc;
}

/**
    Parse command-line arguments

    Processes argv to extract update configuration parameters and device properties.

    Arguments are parsed in two phases:
    1. Named options (--host, --token, etc.) that populate global variables
    2. Remaining key=value pairs that are formatted into a JSON properties string

    The properties string is formatted as: "key1":"value1","key2":"value2",...
    This format is designed to be inserted into a JSON object by the update() function.

    @param argc Number of command-line arguments
    @param argv Array of command-line argument strings
    @return 0 on success (or exits via usage() on error)

    @stability Internal
 */
static int parseArgs(int argc, char **argv)
{
    char   *argp, *dup, *key, *value, pbuf[BUFFER_SIZE];
    size_t mark;
    int    count, nextArg;

    // Set default file path for downloaded update
    file = IMAGE_PATH;

    // Parse named options (arguments starting with '-')
    for (nextArg = 1; nextArg < argc; nextArg++) {
        argp = argv[nextArg];
        if (*argp != '-') {
            break;  // End of named options, remaining args are properties
        }
        if (strcmp(argp, "--cmd") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            cmd = argv[++nextArg];

        } else if (strcmp(argp, "--file") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            file = argv[++nextArg];

        } else if (strcmp(argp, "--host") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            host = argv[++nextArg];

        } else if (strcmp(argp, "--product") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            product = argv[++nextArg];

        } else if (strcmp(argp, "--token") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            token = argv[++nextArg];

        } else if (strcmp(argp, "--device") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            device = argv[++nextArg];

        } else if (strcmp(argp, "--version") == 0) {
            if (nextArg + 1 >= argc) {
                usage();
            }
            version = argv[++nextArg];

        } else if (strcmp(argp, "--verbose") == 0 || strcmp(argp, "-v") == 0) {
            verbose = 1;

        } else {
            usage();  // Unknown option
        }
    }

    // Parse remaining arguments as key=value device properties
    if (argc > nextArg) {
        for (mark = 0; nextArg < argc; nextArg++) {
            // Duplicate the argument so strtok_r doesn't modify argv
            dup = strdup(argv[nextArg]);

            // Split on '=' to extract key and value
            if ((key = strtok_r(dup, "=", &value)) == NULL || value == NULL || *value == '\0') {
                fprintf(stderr, "Invalid property format. Use: key=value\n");
                free(dup);
                usage();
            }

            // Format as JSON: "key":"value",
            count = snprintf(&pbuf[mark], sizeof(pbuf) - mark, "\"%s\":\"%s\",", key, value);
            if (count < 0 || mark + (size_t) count >= sizeof(pbuf)) {
                fprintf(stderr, "Parameter buffer overflow - arguments too long\n");
                free(dup);
                usage();
            }
            mark += (size_t) count;
            free(dup);
        }

        // Remove trailing comma from the last property
        if (*pbuf) {
            pbuf[strlen(pbuf) - 1] = '\0';
        }

        // Allocate and store the properties string for use by update()
        properties = strdup(pbuf);
    }
    return 0;
}

