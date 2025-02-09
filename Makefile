# Makefile for managing the project

install:
    pip install -r requirements.txt

test:
    pytest

run:
    python app.py
