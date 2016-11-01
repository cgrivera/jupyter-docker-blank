FROM ubuntu:14.04

MAINTAINER Corban Rivera


# Install some dependencies
RUN apt-get update && apt-get install -y \
    	curl \
	python-dev && \
	apt-get clean && \
	apt-get autoremove

# Install pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py && \
	rm get-pip.py

# Add SNI support to Python
RUN pip --no-cache-dir install \
		fhirclient

# Install useful Python packages using apt-get to avoid version incompatibilities with Tensorflow binary
# especially numpy, scipy, skimage and sklearn (see https://github.com/tensorflow/tensorflow/issues/2034)
RUN apt-get update && apt-get install -y \
		python-numpy \
		&& \
	apt-get clean && \
	apt-get autoremove && \
	rm -rf /var/lib/apt/lists/*

# Install other useful Python packages using pip
RUN pip --no-cache-dir install --upgrade ipython && \
	pip --no-cache-dir install \
		Cython \
		ipykernel \
		jupyter \
		&& \
	python -m ipykernel.kernelspec



# Set up notebook config
COPY jupyter_notebook_config.py /root/.jupyter/

# Jupyter has issues with being run directly: https://github.com/ipython/ipython/issues/7062
COPY run_jupyter.sh /root/

# Expose Ports for TensorBoard (6006), Ipython (8888)
EXPOSE  8888

#/bin/bash jupyter nbconvert --ExecutePreprocessor.timeout=600 --to notebook --execute mynotebook.ipynb &&
WORKDIR "/root"
CMD ["/root/run_jupyter.sh"]
