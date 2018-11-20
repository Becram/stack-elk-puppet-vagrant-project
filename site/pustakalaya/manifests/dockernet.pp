class pustakalaya::dockernet{
       
     docker_network { 'net-pusta':
             ensure   => present,
             driver   => 'bridge',
     }

 


}



