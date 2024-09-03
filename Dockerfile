# Use an appropriate base image
FROM alpine:latest

# Install necessary packages
RUN apk update && apk add --no-cache bash

# Copy the entrypoint script into the container
COPY entrypoint.sh setup_xmrig.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/setup_xmrig.sh
# Set the entrypoint to the bash script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optionally set a default command, if necessary
CMD ["bash"]
