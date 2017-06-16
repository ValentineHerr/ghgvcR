# our R base image
FROM r-base

# create an R user
ENV HOME /home/ghgvcr
RUN useradd --create-home --home-dir $HOME ghgvcr \
    && mkdir -p $HOME/data \
    && chown -R ghgvcr:ghgvcr $HOME

# install distro libraries for R dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libnetcdf-dev libxml2 curl libxml2-dev libcurl4-openssl-dev libssl-dev wget unzip \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR $HOME
USER ghgvcr

RUN mkdir -p /home/ghgvcr/lib

ENV R_LIBS_USER /home/ghgvcr/lib

# install R dependency packages
RUN Rscript -e "install.packages(c('ggplot2', 'gridExtra', 'Hmisc', 'jsonlite', 'scales', 'tidyr', 'ncdf4', 'Rserve', 'XML', 'devtools'), repos = 'http://cran.us.r-project.org')"

# place the ghgvcR project into the image
COPY . $HOME

# install our project packages
RUN Rscript -e "install.packages('$HOME', repos=NULL, type='source')"

EXPOSE 6311

# set the command
CMD Rscript start.R
