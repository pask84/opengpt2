


FROM continuumio/anaconda3:4.4.0
MAINTAINER Emmanuel Raj, AI Engineer
EXPOSE 8000
WORKDIR /var/www/flask_predict_api/
RUN mkdir models
RUN mkdir models/355M
#RUN gsutils cp gs://gpt2_355m_bucket/checkpoint_the-ascent-355M.tar models/355M
RUN cd models/355M
RUN wget -c https://storage.cloud.google.com/gpt2_355m_bucket/checkpoint_the-ascent-355M.tar && sleep 30s
#RUN tar -C models/355M -xvf checkpoint_the-ascent-355M.tar
RUN ls -ltr
RUN tar -xvf checkpoint_the-ascent-355M.tar
RUN ls
RUN cd /var/www/flask_predict_api/
RUN pip install --upgrade pip
RUN conda remove wrapt --yes
RUN pip uninstall -y setuptools
RUN apt-get update && apt-get install -y apache2 \
    apache2-dev \   
    vim \
 && apt-get clean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/* 
COPY ./flask_predict_api.wsgi /var/www/flask_predict_api/flask_predict_api.wsgi
COPY ./flask_demo /var/www/flask_predict_api/
RUN pip install -r requirements.txt
RUN python3 download_model.py 124M
RUN python3 download_model.py 355M
RUN python3 download_model.py 774M
RUN python3 download_model.py 1558M
RUN /opt/conda/bin/mod_wsgi-express install-module
RUN mod_wsgi-express setup-server flask_predict_api.wsgi --port=8000 \
    --user www-data --group www-data \
    --server-root=/etc/mod_wsgi-express-80
#RUN python3 concatconfigfile.py
CMD /etc/mod_wsgi-express-80/apachectl start -D FOREGROUND
