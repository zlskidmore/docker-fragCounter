# work from latest LTS ubuntu release
FROM ubuntu:18.04

# set variables
ENV r_version 4.1.0
ENV samtools_version 1.10
ENV bcftools_version 1.10
ENV htslib_version 1.10

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
  vim \
  bzip2 \
  libncurses5-dev \
  libncursesw5-dev

# change working dir
WORKDIR /usr/local/bin

# install samtools and related packages
RUN wget https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2
RUN wget https://github.com/samtools/bcftools/releases/download/${bcftools_version}/bcftools-${bcftools_version}.tar.bz2
RUN wget https://github.com/samtools/htslib/releases/download/${htslib_version}/htslib-${htslib_version}.tar.bz2

# extract files for the suite of tools
RUN tar -xjf /usr/local/bin/samtools-${samtools_version}.tar.bz2 -C /usr/local/bin/
RUN tar -xjf /usr/local/bin/bcftools-${bcftools_version}.tar.bz2 -C /usr/local/bin/
RUN tar -xjf /usr/local/bin/htslib-${htslib_version}.tar.bz2 -C /usr/local/bin/

# run make on the source
RUN cd /usr/local/bin/htslib-${htslib_version}/ && ./configure
RUN cd /usr/local/bin/htslib-${htslib_version}/ && make
RUN cd /usr/local/bin/htslib-${htslib_version}/ && make install

RUN cd /usr/local/bin/samtools-${samtools_version}/ && ./configure
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make install

RUN cd /usr/local/bin/bcftools-${bcftools_version}/ && make
RUN cd /usr/local/bin/bcftools-${bcftools_version}/ && make install

# install R
RUN wget https://cran.r-project.org/src/base/R-4/R-${r_version}.tar.gz
RUN tar -zxvf R-${r_version}.tar.gz
WORKDIR /usr/local/bin/R-${r_version}
RUN ./configure --prefix=/usr/local/ --with-x=no
RUN make
RUN make install

# install R packages
RUN R --vanilla -e 'install.packages(c("devtools", "BiocManager"), repos="http://cran.us.r-project.org")'
RUN R --vanilla -e 'devtools::install_version("data.table", version = "1.12.8", repos = "http://cran.us.r-project.org")'
RUN R --vanilla -e 'BiocManager::install(c("BiocGenerics","GenomicRanges","rtracklayer","Biostrings","DNAcopy","GenomeInfoDb","IRanges","Rsamtools","rtracklayer"))'
RUN R --vanilla -e 'install.packages(c("optparse","testhat"), repos = "http://cran.us.r-project.org")'
RUN R --vanilla -e 'devtools::install_github("zlskidmore/fragCounter")'
RUN R --vanilla -e 'BiocManager::install(c("rtracklayer"))'

# set some environment/path vars
ENV PATH="${PATH}:/usr/local/lib/R/library/fragCounter/extdata/"

