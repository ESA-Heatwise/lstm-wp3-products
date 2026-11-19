FROM mambaorg/micromamba:2.9.0-ubuntu24.04
COPY --chown=mambauser:mambauser Dockerfile Dockerfile
COPY --chown=mambauser:mambauser environment.yml environment.yml
COPY --chown=mambauser:mambauser build-includes ./
RUN micromamba install -y -n base -f environment.yml && \
  micromamba clean --all --yes
RUN micromamba env export --md5 >exact-environment.yml
WORKDIR /home/mambauser
COPY --chown=mambauser:mambauser runtime-includes ./
COPY --chown=mambauser:mambauser user_code.py user_code.py
COPY --chown=mambauser:mambauser execute.py execute.py
COPY --chown=mambauser:mambauser parameters.yaml parameters.yaml
COPY --chown=mambauser:mambauser parameters.py parameters.py
COPY --chown=mambauser:mambauser util.py util.py
ENTRYPOINT [ \
  "/usr/local/bin/_entrypoint.sh", \
  "python", \
  "/home/mambauser/execute.py" \
]
