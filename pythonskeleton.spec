%define name pythonskeleton
%define home /opt/pythonskeleton

# disable building of the debug package
%define  debug_package %{nil}

%define user %{name}
%define logdir %{home}/var/log/%{name}
%define tmpdir %{home}/var/tmp
%define service %{name}
%define libdir %{home}/lib/%{name}

# do not know how to get site packages in a spec file
%define sitepackages_path /usr/lib/python2.6/site-packages/


Summary: Python Skeleton Package
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{version}.tar.gz
License: © Telefonica Digital
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
BuildArch: x86_64
Vendor: Telefonica Digital
AutoReq: no

%description
%{Summary}

%prep
%setup -n %{name}-%{version}

%build

%install
make install HOME_DIR=%{home} RPM_BUILD_ROOT=$RPM_BUILD_ROOT \
	     LIB_DIR=%{libdir} INSTALLED_FILES=INSTALLED_FILES \
	     SITEPACKAGES_PATH=%{sitepackages_path}
make build-libs RPM_BUILD_ROOT=$RPM_BUILD_ROOT LIB_DIR=%{libdir} \
		SITEPACKAGES_PATH=%{sitepackages_path}

%pre
groupadd -r -f %{user}
grep \^%{name} /etc/passwd >/dev/null
if [ $? -ne 0 ]; then
  useradd -d %{libdir} -g %{user} -M -r %{user}
fi
#Check old version service is running
/sbin/service %{service} status 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    # Service is running -> stop service
    /sbin/service %{service} stop 
fi

%post
chown %{user}:%{user} %{libdir} 
chmod g+s %{libdir}  
if [ "$(ls -A %{libdir})" ]; then
    chown -R %{user}:%{user} %{libdir}/*
fi


if [ ! -d %{logdir} ]; then 
    mkdir -p %{logdir}
fi
chown %{user}:%{user} %{logdir} 
chmod g+s %{logdir} 
if [ "$(ls -A %{logdir})" ]; then
    chown -R %{user}:%{user} %{logdir}/*
fi

if [ ! -d %{home}/var/run/%{name} ]; then 
    mkdir -p %{home}/var/run/%{name}
fi
chown %{user}:%{user} %{home}/var/run/%{name}

if [ ! -d %{home}/var/lock/%{name} ]; then 
    mkdir -p %{home}/var/lock/%{name}
fi
chown %{user}:%{user} %{home}/var/lock/%{name}



if [ ! -d %{tmpdir} ]; then
    mkdir -p  %{tmpdir}
    chmod 777 %{tmpdir}
fi

# Init files:                                                                   
# - %{name} relies on %{name}runner to run
# - %{name}runner executes the command to run and annotates the PID
chmod +x %{home}/etc/init.d/%{name}runner                           
chmod +x %{home}/etc/init.d/%{name}                          
ln -sf %{home}/etc/init.d/%{name} /etc/init.d/%{name}

# Added logrotate and make it an hourly cron task
(
cat <<'FROMHERE'
%{logdir}/*.log
{
    daily
    minsize 90M
    rotate 10
    missingok
    create 640 %{user} %{user}  
    notifempty
    compress
}
FROMHERE
)>/etc/logrotate.d/%{name}

if [[ -f /etc/cron.daily/logrotate ]]; then
    mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
fi


%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES 
%defattr(-,root,root)
%config(noreplace) %{home}/etc/%{name}/logging.conf
%config(noreplace) %{home}/etc/%{name}/%{name}.conf
%{home}/bin/%{name}
%{home}/lib/%{name}/
%{sitepackages_path}/%{name}libs.pth
%{sitepackages_path}/%{name}.pth

%changelog

