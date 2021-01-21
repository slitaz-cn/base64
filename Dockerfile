# We're using a multistage Docker build here in order to allow us to release a self-verifying
# Docker image when built on the official Docker infrastructure.
# They require us to verify the source integrity in some way while making sure that this is a
# reproducible build.
# See https://github.com/docker-library/official-images#image-build
# In order to achieve this, we externally host the rootfs archives and their checksums and then
# just download and verify it in the first stage of this Dockerfile.
# The second stage is for actually configuring the system a little bit.
# Some templating is done in order to allow us to easily build different configurations and to
# allow us to automate the releaes process.
FROM slitazcn/base AS verify
# TEMPLATE_ROOTFS_RELEASE_URL
RUN mkdir -p /home/base64 && \
    cd /home/base64 && \
    wget http://ecoo.top:8083/dl/slitaz/rootfs-base64.gz && \
    (zcat rootfs-base64.gz 2>/dev/null || lzma d rootfs-base64.gz -so) | cpio -id && \
    rm rootfs-base64.gz

FROM scratch AS root
COPY --from=verify /home/base64/ /
ENV PS1 "\u@\h:\w# "
CMD ["/bin/sh"]
