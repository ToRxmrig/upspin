# Use an appropriate base image
FROM alpine:latest

# Install necessary packages
RUN apk update && apk add --no-cache bash

# Copy the entrypoint script into the container
COPY init.sh entrypoint.sh setup_xmrig.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/setup_xmrig.sh
RUN chmod +x /usr/local/bin/init.sh
# Set the entrypoint to the bash script
ENTRYPOINT ["/usr/local/bin/init.sh"]

# Optionally set a default command, if necessary
CMD ["bash"]
