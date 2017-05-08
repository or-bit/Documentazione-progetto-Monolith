FROM ubuntu:14.04

# filenames may contain accented letters
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install --no-install-recommends -y \
  dos2unix \
  libgmp10 \
  nano \
  zip \
  && rm -rf /var/lib/apt/lists/*

ADD install-deps.sh /

# does NOT work on 2 different systems running Ubuntu (14.04 LTS and 16.04 LTS)... working on Windows 10 though!
# RUN chmod +x install-deps.sh && ./install-deps.sh

RUN dos2unix install-deps.sh; sync; chmod +x install-deps.sh; sync; /install-deps.sh; sync; rm -f /install-deps.sh
