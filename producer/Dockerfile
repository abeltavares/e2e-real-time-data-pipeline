FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY producer.py .

#(optional, for debugging)
EXPOSE 5000

CMD ["python", "producer.py"]
