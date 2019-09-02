{% for ip in grains['host_ips'] %}
# an hostname entry is: # dmadog2-hana01
# we remove the last 2 chars dmadog2-hana for appending both hostname with loop.indes
# results: dmadog2-hana01 and dmadog2hana02 
{{ grains['hostname'][:-2] }}{{ '{:0>2}'.format(loop.index) }}:
  host.present:
    - ip: {{ ip }}
    - names:
      - {{ grains['hostname'][:-2] }}{{ '{:0>2}'.format(loop.index) }}
{% endfor %}
