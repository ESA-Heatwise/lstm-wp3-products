FROM mambaorg/micromamba:1.5.10-noble-cuda-12.6.0
COPY Dockerfile Dockerfile
COPY environment.yml environment.yml
RUN micromamba install -y -n base -f environment.yml && \
  micromamba clean --all --yes
WORKDIR /home/mambauser
COPY user_code.py user_code.py
COPY execute.py execute.py
COPY parameters.yaml parameters.yaml
COPY parameters.py parameters.py
COPY util.py util.py
ENTRYPOINT [ \
  "/usr/local/bin/_entrypoint.sh", \
  "python", \
  "/home/mambauser/execute.py" \
]
