FROM ubuntu:17.10
LABEL "flask_k8_test_app"="1.0"


RUN \
  apt-get update && \
  apt-get install -y python3-dev python3-pip nginx build-essential libpcre3 libpcre3-dev


EXPOSE 7575


ADD . /app
WORKDIR /app

RUN pip3 install -r requirements.txt
RUN chown -R www-data:www-data /app
RUN cp /app/nginx.conf /etc/nginx/sites-available/flask_k8_test_app
RUN ln -s /etc/nginx/sites-available/flask_k8_test_app /etc/nginx/sites-enabled

#CMD ["bash"]
CMD /app/startup.sh
#ENTRYPOINT ["service nginx restart"]