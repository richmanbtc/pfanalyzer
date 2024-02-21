FROM jupyter/datascience-notebook:python-3.10.6

USER root

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
    yfinance==0.2.36 \
    beautifulsoup4==4.12.3

WORKDIR /app
CMD python -m src.main
