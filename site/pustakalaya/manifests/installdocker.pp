class pustakalaya::installdocker{

       exec {'install docker': 
               command => '/usr/bin/curl -fsSL https://get.docker.com/ | sh'
       }
       
       service { 'docker':
            name       => 'docker',
            ensure     => running,
            enable     => true,
      }

      class { 'docker':
           notify => Service['docker'],
           docker_users => ['vagrant'],

      }  
         


}



