# mantraOS Educational Kit build environment
FROM pandoc/latex:latest

# Install extra LaTeX packages & fonts
RUN apt-get update && \
    apt-get install -y \
      fonts-noto fonts-noto-unhinted fonts-noto-cjk \
      texlive-xetex texlive-fonts-extra make && \
    rm -rf /var/lib/apt/lists/*

# Default workdir
WORKDIR /workspace

# Entry: run make
CMD ["make", "all"]
