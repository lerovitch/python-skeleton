python-skeleton
===============

This skeleteon aims to help the creation a python application following this       
structure:                                                                         
                                                                                   
<table>                                                                            
    <tr>                                                                           
        <td>$HOME/bin</td>                                                         
        <td>Binary files. Script launching the app, will be generated by           
setup.py install as configured in setup.py</td>                                    
        <td>-</td>                                                                 
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/etc/init.d</td>                                                  
        <td>Start/Stop files of UNIX services</td>                                 
        <td>/etc/init.d</td>                                                       
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/etc/$NAME</td>                                                   
        <td>Basic configuration of the module. Logging and properties will be   
placed there.</td>                                                                 
        <td>-</td>                                                                 
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/etc/logrotate.d/$NAME</td>                                       
        <td>Logrotate configuration</td>                                           
        <td>/etc/logrotate.d</td>                                                  
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/lib/$NAME/python</td>                                            
        <td>Python source code of the application</td>                             
        <td>-</td>                                                                 
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/lib/$NAME/libs</td>                                              
        <td>Third parties libs</td>                                                
        <td>-</td>                                                                 
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/var/log/$NAME</td>                                               
        <td></td>                                                                  
        <td></td>                                                                  
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/var/run/$NAME</td>                                               
        <td>Files describing when the module is started. Pid files.</td>           
        <td>-</td>                                                                 
    </tr>                                                                          
    <tr>                                                                           
        <td>$HOME/var/tmp/$NAME</td>                                               
        <td>temporary folder but preserved between reboots</td>                    
        <td>-</td>                                                                 
    </tr> 
</table>


Basic Configuration
-------------------

This basic configuration includes:

- UNIX service files
- Generation of binary file in setup.py executing the python function main:main
- Generates a RPM package
- python source files to $HOME/lib/$NAME/python
- python dependencies to $HOME/lib/$NAME/libs
- python configuration files to $HOME/etc/$NAME

customizing it
---------------

- Edit `pythonskeleton.spec`. And change `name` and `home` accordingly

    %define name pythonskeleton
    %define home /opt/pythonskeleton
  
- Edit `hudson_build.sh`. Change `NAME` variable

    NAME=pythonskeleton
  
- Edit setup.py. Change `dist_name` variable

     dist_name = "pythonskeleton"
     
- Edit Makefile.

    NAME=pythonskeleton
    PACKAGE_NAME=pythonskeleton
    
    
Conventions
-----------

Some things have been taken as conventions but you might configure it according your needs

- `name` variable defines the binary file, service name, username, and any folder name identifying the component
