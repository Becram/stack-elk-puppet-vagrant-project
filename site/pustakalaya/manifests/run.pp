class pustakalaya::run{
#       exec {'stop-delete-containers': command => "/usr/bin/docker kill $(/usr/bin/docker ps -q) && /usr/bin/docker rm $(/usr/bin/docker ps -a -q) && /bin/rm -rfv /var/run/docker-*"}
       docker::run { 'pgmaster':
              image   => 'becram/olen-elib-db-master:v5.2.0',
              net     => 'net-pusta',
              env_file  => ['/vagrant/conf/pgmaster.env'],
              service_prefix  => 'docker-',
              restart =>  'always',
              volumes => ['production_postgres_data_master:/var/lib/postgresql/data'],
       }  


       docker::run { 'elastic':
              image   => 'becram/olen-elib-elastic:v5.2.0',
              restart =>  'always',
              service_prefix  => 'docker-',
              net     => 'net-pusta',
              depends => [ 'pgmaster' ],
              volumes => ['production_elastic_data:/usr/share/elasticsearch/data'],
              extra_parameters => ['-e ES_JAVA_OPTS="-Xms1g  -Xmx1g"']
       }
 

       docker::run { 'pgslave':
              image   => 'becram/olen-elib-db-slave:v5.2.0',
              restart =>  'always',
              service_prefix  => 'docker-',
              env_file  => ['/vagrant/conf/pgslave.env'],
              net     => 'net-pusta',
              depends => [ 'pgmaster' ],
              volumes => ['production_postgres_data_slave:/var/lib/postgresql/data'],
       }


       docker::run { 'rabbitmq':
              image   => 'rabbitmq:3.7',
              restart =>  'always',
              service_prefix  => 'docker-',
              net     => 'net-pusta',
              extra_parameters => ['-e RABBITMQ_DEFAULT_USER=admin -e RABBITMQ_DEFAULT_PASS=mypass']
       }



       docker::run { 'celery':
              image   => 'becram/olen-elib-celery:v5.2.0',
              restart =>  'always',
              service_prefix  => 'docker-',
              net     => 'net-pusta',
              depends => [ 'pgmaster','rabbitmq' ],
              extra_parameters => ['--restart=always']
       }
       docker::run { 'code':
              image   => 'becram/olen-elib-code:v5.2.0',
              restart =>  'always',
              volumes => ['/library/media_root:/library/media_root:rw', '/library/static_root:/library/static_root:rw'],
              service_prefix  => 'docker-',
              env_file  => ['/vagrant/conf/code.env'],
              net     => 'net-pusta',
              depends => [ 'pgmaster','rabbitmq','elastic','pgslave','celery' ],
              extra_parameters => ['-e DJANGO_SETTINGS_MODULE=pustakalaya.settings.production']
       }
       
       docker::run { 'nginx':
              image   => 'becram/olen-elib-nginx:v5.2.0',
              restart =>  'always',
              ports => ["80:8000"],
              volumes => ['/library/media_root:/library/media_root:rw', '/library/static_root:/library/static_root:rw'],
              service_prefix  => 'docker-',
              net     => 'net-pusta',
              depends => [ 'code' ],
              extra_parameters => ['-e DJANGO_SETTINGS_MODULE=pustakalaya.settings.production']
       }


  

}



