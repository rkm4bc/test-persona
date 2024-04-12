apiVersion: pxc.percona.com/v1
kind: PerconaXtraDBCluster
metadata:
  name: cluster2
  finalizers:
    - delete-pxc-pods-in-order
#    - delete-ssl
#    - delete-proxysql-pvc
#    - delete-pxc-pvc
#  annotations:
#    percona.com/issue-vault-token: "true"
spec:
  crVersion: 1.14.0
#  ignoreAnnotations:
#    - iam.amazonaws.com/role
#  ignoreLabels:
#    - rack
  secretsName: cluster2-secrets
  vaultSecretName: keyring-secret-vault
  sslSecretName: cluster2-ssl
  sslInternalSecretName: cluster2-ssl-internal
  logCollectorSecretName: cluster2-log-collector-secrets
  initContainer:
    image: docker.io/perconalab/percona-xtradb-cluster-operator:main
    resources:
      requests:
        memory: 100M
        cpu: 100m
      limits:
        memory: 200M
        cpu: 200m
#  enableCRValidationWebhook: true
#  tls:
#    SANs:
#      - pxc-1.example.com
#      - pxc-2.example.com
#      - pxc-3.example.com
#    issuerConf:
#      name: special-selfsigned-issuer
#      kind: ClusterIssuer
#      group: cert-manager.io
  allowUnsafeConfigurations: true
#  pause: false
  updateStrategy: SmartUpdate
  upgradeOptions:
    versionServiceEndpoint: https://check.percona.com
    apply: disabled
    schedule: "0 4 * * *"
  pxc:
    size: 3
    image: docker.io/perconalab/percona-xtradb-cluster-operator:main-pxc8.0
    autoRecovery: true
#    expose:
#      enabled: true
#      type: LoadBalancer
#      externalTrafficPolicy: Local
#      internalTrafficPolicy: Local
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#      annotations:
#        networking.gke.io/load-balancer-type: "Internal"
#      labels:
#        rack: rack-22
#    replicationChannels:
#    - name: pxc1_to_pxc2
#      isSource: true
#    - name: pxc2_to_pxc1
#      isSource: false
#      configuration:
#        sourceRetryCount: 3
#        sourceConnectRetry: 60
#        ssl: false
#        sslSkipVerify: true
#        ca: '/etc/mysql/ssl/ca.crt'
#      sourcesList:
#      - host: 10.95.251.101
#        port: 3306
#        weight: 100
#    schedulerName: mycustom-scheduler
#    readinessDelaySec: 15
#    livenessDelaySec: 600
#    configuration: |
#      [mysqld]
#      socket.ssl=YES   
#      wsrep_debug=CLIENT
#      wsrep_provider_options="gcache.size=1G; gcache.recover=yes"
#      [sst]
#      xbstream-opts=--decompress
#      [xtrabackup]
#      compress=lz4
#      for PXC 5.7
#      [xtrabackup]
#      compress
#    imagePullSecrets:
#      - name: private-registry-credentials
#    priorityClassName: high-priority
#    annotations:
#      iam.amazonaws.com/role: role-arn
#    labels:
#      rack: rack-22
#    readinessProbes:
#      initialDelaySeconds: 15
#      timeoutSeconds: 15
#      periodSeconds: 30
#      successThreshold: 1
#      failureThreshold: 5
#    livenessProbes:
#      initialDelaySeconds: 300
#      timeoutSeconds: 5
#      periodSeconds: 10
#      successThreshold: 1
#      failureThreshold: 3
#    containerSecurityContext:
#      privileged: false
#    podSecurityContext:
#      runAsUser: 1001
#      runAsGroup: 1001
#      supplementalGroups: [1001]
#    serviceAccountName: percona-xtradb-cluster-operator-workload
#    imagePullPolicy: Always
#    runtimeClassName: image-rc
#    sidecars:
#    - image: busybox
#      command: ["/bin/sh"]
#      args: ["-c", "while true; do trap 'exit 0' SIGINT SIGTERM SIGQUIT SIGKILL; done;"]
#      name: my-sidecar-1
#      resources:
#        requests:
#          memory: 100M
#          cpu: 100m
#        limits:
#          memory: 200M
#          cpu: 200m
#    envVarsSecret: my-env-var-secrets
    resources:
      requests:
        memory: 1G
        cpu: 600m
#        ephemeral-storage: 1G
#      limits:
#        memory: 1G
#        cpu: "1"
#        ephemeral-storage: 1G
#    nodeSelector:
#      disktype: ssd
#    topologySpreadConstraints:
#    - labelSelector:
#        matchLabels:
#          app.kubernetes.io/name: percona-xtradb-cluster
#      maxSkew: 1
#      topologyKey: kubernetes.io/hostname
#      whenUnsatisfiable: DoNotSchedule
    affinity:
      antiAffinityTopologyKey: "kubernetes.io/hostname"
#      advanced:
#        nodeAffinity:
#          requiredDuringSchedulingIgnoredDuringExecution:
#            nodeSelectorTerms:
#            - matchExpressions:
#              - key: kubernetes.io/e2e-az-name
#                operator: In
#                values:
#                - e2e-az1
#                - e2e-az2
#    tolerations:
#    - key: "node.alpha.kubernetes.io/unreachable"
#      operator: "Exists"
#      effect: "NoExecute"
#      tolerationSeconds: 6000
    podDisruptionBudget:
      maxUnavailable: 1
#      minAvailable: 0
    volumeSpec:
#      emptyDir: {}
#      hostPath:
#        path: /data
#        type: Directory
      persistentVolumeClaim:
        storageClassName: longhorn
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 6G
    gracePeriod: 600
#    lifecycle:
#      preStop:
#        exec:
#          command: [ "/bin/true" ]
#      postStart:
#        exec:
#          command: [ "/bin/true" ]
  haproxy:
    enabled: true
    size: 2
    image: docker.io/perconalab/percona-xtradb-cluster-operator:main-haproxy
#    imagePullPolicy: Always
#    schedulerName: mycustom-scheduler
#    readinessDelaySec: 15
#    livenessDelaySec: 600
#    configuration: |
#
#    the actual default configuration file can be found here https://github.com/percona/percona-docker/blob/main/haproxy/dockerdir/etc/haproxy/haproxy-global.cfg
#
#      global
#        maxconn 2048
#        external-check
#        insecure-fork-wanted
#        stats socket /etc/haproxy/pxc/haproxy.sock mode 600 expose-fd listeners level admin
#
#      defaults
#        default-server init-addr last,libc,none
#        log global
#        mode tcp
#        retries 10
#        timeout client 28800s
#        timeout connect 100500
#        timeout server 28800s
#
#      resolvers kubernetes
#        parse-resolv-conf
#
#      frontend galera-in
#        bind *:3309 accept-proxy
#        bind *:3306
#        mode tcp
#        option clitcpka
#        default_backend galera-nodes
#
#      frontend galera-admin-in
#        bind *:33062
#        mode tcp
#        option clitcpka
#        default_backend galera-admin-nodes
#
#      frontend galera-replica-in
#        bind *:3307
#        mode tcp
#        option clitcpka
#        default_backend galera-replica-nodes
#
#      frontend galera-mysqlx-in
#        bind *:33060
#        mode tcp
#        option clitcpka
#        default_backend galera-mysqlx-nodes
#
#      frontend stats
#        bind *:8404
#        mode http
#        option http-use-htx
#        http-request use-service prometheus-exporter if { path /metrics }
#    imagePullSecrets:
#      - name: private-registry-credentials
#    annotations:
#      iam.amazonaws.com/role: role-arn
#    labels:
#      rack: rack-22
#    readinessProbes:
#      initialDelaySeconds: 15
#      timeoutSeconds: 1
#      periodSeconds: 5
#      successThreshold: 1
#      failureThreshold: 3
#    livenessProbes:
#      initialDelaySeconds: 60
#      timeoutSeconds: 5
#      periodSeconds: 30
#      successThreshold: 1
#      failureThreshold: 4
#    exposePrimary:
#      enabled: false
#      type: ClusterIP
#      annotations:
#        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
#      externalTrafficPolicy: Cluster
#      internalTrafficPolicy: Cluster
#      labels:
#        rack: rack-22
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#    exposeReplicas:
#      enabled: false
#      type: ClusterIP
#      annotations:
#        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
#      externalTrafficPolicy: Cluster
#      internalTrafficPolicy: Cluster
#      labels:
#        rack: rack-22
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#    runtimeClassName: image-rc
#    sidecars:
#    - image: busybox
#      command: ["/bin/sh"]
#      args: ["-c", "while true; do trap 'exit 0' SIGINT SIGTERM SIGQUIT SIGKILL; done;"]
#      name: my-sidecar-1
#      resources:
#        requests:
#          memory: 100M
#          cpu: 100m
#        limits:
#          memory: 200M
#          cpu: 200m
#    envVarsSecret: my-env-var-secrets
    resources:
      requests:
        memory: 1G
        cpu: 600m
#      limits:
#        memory: 1G
#        cpu: 700m
#    priorityClassName: high-priority
#    nodeSelector:
#      disktype: ssd
#    sidecarResources:
#      requests:
#        memory: 1G
#        cpu: 500m
#      limits:
#        memory: 2G
#        cpu: 600m
#    containerSecurityContext:
#      privileged: false
#    podSecurityContext:
#      runAsUser: 1001
#      runAsGroup: 1001
#      supplementalGroups: [1001]
#    serviceAccountName: percona-xtradb-cluster-operator-workload
#    topologySpreadConstraints:
#    - labelSelector:
#        matchLabels:
#          app.kubernetes.io/name: percona-xtradb-cluster
#      maxSkew: 1
#      topologyKey: kubernetes.io/hostname
#      whenUnsatisfiable: DoNotSchedule
    affinity:
      antiAffinityTopologyKey: "kubernetes.io/hostname"
#      advanced:
#        nodeAffinity:
#          requiredDuringSchedulingIgnoredDuringExecution:
#            nodeSelectorTerms:
#            - matchExpressions:
#              - key: kubernetes.io/e2e-az-name
#                operator: In
#                values:
#                - e2e-az1
#                - e2e-az2
#    tolerations:
#    - key: "node.alpha.kubernetes.io/unreachable"
#      operator: "Exists"
#      effect: "NoExecute"
#      tolerationSeconds: 6000
    podDisruptionBudget:
      maxUnavailable: 1
#      minAvailable: 0
    gracePeriod: 30
#    lifecycle:
#      preStop:
#        exec:
#          command: [ "/bin/true" ]
#      postStart:
#        exec:
#          command: [ "/bin/true" ]
  proxysql:
    enabled: false
    size: 3
    image: perconalab/percona-xtradb-cluster-operator:main-proxysql
#    imagePullPolicy: Always
#    configuration: |
#      datadir="/var/lib/proxysql"
#
#      admin_variables =
#      {
#        admin_credentials="proxyadmin:admin_password"
#        mysql_ifaces="0.0.0.0:6032"
#        refresh_interval=2000
#
#        cluster_username="proxyadmin"
#        cluster_password="admin_password"
#        checksum_admin_variables=false
#        checksum_ldap_variables=false
#        checksum_mysql_variables=false
#        cluster_check_interval_ms=200
#        cluster_check_status_frequency=100
#        cluster_mysql_query_rules_save_to_disk=true
#        cluster_mysql_servers_save_to_disk=true
#        cluster_mysql_users_save_to_disk=true
#        cluster_proxysql_servers_save_to_disk=true
#        cluster_mysql_query_rules_diffs_before_sync=1
#        cluster_mysql_servers_diffs_before_sync=1
#        cluster_mysql_users_diffs_before_sync=1
#        cluster_proxysql_servers_diffs_before_sync=1
#      }
#
#      mysql_variables=
#      {
#        monitor_password="monitor"
#        monitor_galera_healthcheck_interval=1000
#        threads=2
#        max_connections=2048
#        default_query_delay=0
#        default_query_timeout=10000
#        poll_timeout=2000
#        interfaces="0.0.0.0:3306"
#        default_schema="information_schema"
#        stacksize=1048576
#        connect_timeout_server=10000
#        monitor_history=60000
#        monitor_connect_interval=20000
#        monitor_ping_interval=10000
#        ping_timeout_server=200
#        commands_stats=true
#        sessions_sort=true
#        have_ssl=true
#        ssl_p2s_ca="/etc/proxysql/ssl-internal/ca.crt"
#        ssl_p2s_cert="/etc/proxysql/ssl-internal/tls.crt"
#        ssl_p2s_key="/etc/proxysql/ssl-internal/tls.key"
#        ssl_p2s_cipher="ECDHE-RSA-AES128-GCM-SHA256"
#      }
#    readinessDelaySec: 15
#    livenessDelaySec: 600
#    schedulerName: mycustom-scheduler
#    imagePullSecrets:
#      - name: private-registry-credentials
#    annotations:
#      iam.amazonaws.com/role: role-arn
#    labels:
#      rack: rack-22
#    expose:
#      enabled: false
#      type: ClusterIP
#      annotations:
#        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
#      externalTrafficPolicy: Cluster
#      internalTrafficPolicy: Cluster
#      labels:
#        rack: rack-22
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#    runtimeClassName: image-rc
#    sidecars:
#    - image: busybox
#      command: ["/bin/sh"]
#      args: ["-c", "while true; do trap 'exit 0' SIGINT SIGTERM SIGQUIT SIGKILL; done;"]
#      name: my-sidecar-1
#      resources:
#        requests:
#          memory: 100M
#          cpu: 100m
#        limits:
#          memory: 200M
#          cpu: 200m
#    envVarsSecret: my-env-var-secrets
    resources:
      requests:
        memory: 1G
        cpu: 600m
#      limits:
#        memory: 1G
#        cpu: 700m
#    priorityClassName: high-priority
#    nodeSelector:
#      disktype: ssd
#    sidecarResources:
#      requests:
#        memory: 1G
#        cpu: 500m
#      limits:
#        memory: 2G
#        cpu: 600m
#    containerSecurityContext:
#      privileged: false
#    podSecurityContext:
#      runAsUser: 1001
#      runAsGroup: 1001
#      supplementalGroups: [1001]
#    serviceAccountName: percona-xtradb-cluster-operator-workload
#    topologySpreadConstraints:
#    - labelSelector:
#        matchLabels:
#          app.kubernetes.io/name: percona-xtradb-cluster-operator
#      maxSkew: 1
#      topologyKey: kubernetes.io/hostname
#      whenUnsatisfiable: DoNotSchedule
    affinity:
      antiAffinityTopologyKey: "kubernetes.io/hostname"
#      advanced:
#        nodeAffinity:
#          requiredDuringSchedulingIgnoredDuringExecution:
#            nodeSelectorTerms:
#            - matchExpressions:
#              - key: kubernetes.io/e2e-az-name
#                operator: In
#                values:
#                - e2e-az1
#                - e2e-az2
#    tolerations:
#    - key: "node.alpha.kubernetes.io/unreachable"
#      operator: "Exists"
#      effect: "NoExecute"
#      tolerationSeconds: 6000
    volumeSpec:
#      emptyDir: {}
#      hostPath:
#        path: /data
#        type: Directory
      persistentVolumeClaim:
#        storageClassName: standard
#        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 2G
    podDisruptionBudget:
      maxUnavailable: 1
#      minAvailable: 0
    gracePeriod: 30
#    lifecycle:
#      preStop:
#        exec:
#          command: [ "/bin/true" ]
#      postStart:
#        exec:
#          command: [ "/bin/true" ]
#   loadBalancerSourceRanges:
#     - 10.0.0.0/8
  logcollector:
    enabled: true
    image: docker.io/perconalab/percona-xtradb-cluster-operator:main-logcollector
#    configuration: |
#      [OUTPUT]
#           Name  es
#           Match *
#           Host  192.168.2.3
#           Port  9200
#           Index my_index
#           Type  my_type
    resources:
      requests:
        memory: 100M
        cpu: 200m
  pmm:
    enabled: false
    image: docker.io/percona/pmm-client:2.41.1
    serverHost: monitoring-service
#    serverUser: admin
#    pxcParams: "--disable-tablestats-limit=2000"
#    proxysqlParams: "--custom-labels=CUSTOM-LABELS"
#    containerSecurityContext:
#      privileged: false
    resources:
      requests:
        memory: 150M
        cpu: 300m
  backup:
#    allowParallel: true
    image: docker.io/perconalab/percona-xtradb-cluster-operator:main-pxc8.0-backup
#    backoffLimit: 6
    serviceAccountName: percona-xtradb-cluster-operator
#    allowUnsafeConfigurations: true
#    imagePullSecrets:
#      - name: private-registry-credentials
    pitr:
      enabled: false
      storageName: fs-pvc
      timeBetweenUploads: 60
      timeoutSeconds: 60
#      resources:
#        requests:
#          memory: 0.1G
#          cpu: 100m
#        limits:
#          memory: 1G
#          cpu: 700m
    storages: 
      ceph-s3-us-west:
        type: s3
        verifyTLS: false
        s3:
          bucket: percona-backups-test
          credentialsSecret: backup-ceph-s3
          endpointUrl: https://machi-nas-s.hpc.virginia.edu:7480
#          region: us-east-2
#          bucket: backup-percona
#          credentialsSecret: my-cluster-name-backup-s3
#          region: us-east-2
#      azure-blob:
#        type: azure
#        azure:
#          credentialsSecret: azure-secret
#          container: test
#          endpointUrl: https://accountName.blob.core.windows.net
#          storageClass: Hot
      fs-pvc:
        type: filesystem
#        nodeSelector:
#          storage: tape
#          backupWorker: 'True'
#        resources:
#          requests:
#            memory: 1G
#            cpu: 600m
#        topologySpreadConstraints:
#        - labelSelector:
#            matchLabels:
#              app.kubernetes.io/name: percona-xtradb-cluster
#          maxSkew: 1
#          topologyKey: kubernetes.io/hostname
#          whenUnsatisfiable: DoNotSchedule
#        affinity:
#          nodeAffinity:
#            requiredDuringSchedulingIgnoredDuringExecution:
#              nodeSelectorTerms:
#              - matchExpressions:
#                - key: backupWorker
#                  operator: In
#                  values:
#                  - 'True'
#        tolerations:
#          - key: "backupWorker"
#            operator: "Equal"
#            value: "True"
#            effect: "NoSchedule"
#        annotations:
#          testName: scheduled-backup
#        labels:
#          backupWorker: 'True'
#        schedulerName: 'default-scheduler'
#        priorityClassName: 'high-priority'
#        containerSecurityContext:
#          privileged: true
#        podSecurityContext:
#          fsGroup: 1001
#          supplementalGroups: [1001, 1002, 1003]
        volume:
          persistentVolumeClaim:
#            claimName: fs-pvc
            storageClassName: longhorn
            accessModes: [ "ReadWriteOnce" ]
            resources:
              requests:
                storage: 1G
    schedule:
      - name: "daily-backup"
        schedule: "0 */6 * * *"
        keep: 3
        storageName: ceph-s3-us-west
      - name: "hourly-backup"
        schedule: "0 9 * * TUE"
        keep: 2
        storageName: fs-pvc
