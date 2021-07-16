# work from latest LTS ubuntu release
FROM ubuntu:18.04

# set variables
ENV r_version 4.1.0

# run update
RUN apt-get update -y && apt-get install -y \
  gfortran \
  libreadline-dev \
  libpcre3-dev \
  libcurl4-openssl-dev \
  build-essential \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  openjdk-8-jdk \
  wget \
  libssl-dev \
  libxml2-dev \
  libnss-sss \
  libpcre2-dev \
  libfreetype6-dev \
  libfontconfig1-dev \
  git \
  less \
  vim

# change working dir
WORKDIR /usr/local/bin

# install R
RUN wget https://cran.r-project.org/src/base/R-4/R-${r_version}.tar.gz
RUN tar -zxvf R-${r_version}.tar.gz
WORKDIR /usr/local/bin/R-${r_version}
RUN ./configure --prefix=/usr/local/ --with-x=no
RUN make
RUN make install

# install R packages
RUN R --vanilla -e 'install.packages(c("devtools", "BiocManager"), repos="http://cran.us.r-project.org")'
RUN R --vanilla -e 'BiocManager::install(c("BiocGenerics","GenomicRanges","rtracklayer","Biostrings","DNAcopy","GenomeInfoDb","IRanges","Rsamtools"))'
RUN R --vanilla -e 'install.packages(c("optparse","data.table","testhat"), repos = "http://cran.us.r-project.org")'
RUN R --vanilla -e 'devtools::install_github("mskilab/fragCounter")'

# set some environment/path vars
ENV PATH="${PATH}:/usr/local/lib/R/library/fragCounter/extdata/"

