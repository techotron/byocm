FROM grafana/grafana

ADD cadvisor_exporter_dashboard.json /var/lib/grafana/dashboards/cadvisor_exporter_dashboard.json
ADD node_exporter_dashboard.json /var/lib/grafana/dashboards/node_exporter_dashboard.json

ADD datasources.yml /etc/grafana/provisioning/datasources/prometheus.yaml
ADD dashboards.yml /etc/grafana/provisioning/dashboards/all.yml

ENV GF_SECURITY_ADMIN_PASSWORD="password"

EXPOSE 3000