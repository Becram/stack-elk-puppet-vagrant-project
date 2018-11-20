class pustakalaya::pull{

    $pustakalaya_images= ['becram/olen-elib-nginx','becram/olen-elib-code','becram/olen-elib-db-master','becram/olen-elib-db-slave','becram/olen-elib-elastic','becram/olen-elib-celery']

    docker::image { $pustakalaya_images:
       image_tag => 'v5.2.0',
       ensure => 'present'
    }

 


}



