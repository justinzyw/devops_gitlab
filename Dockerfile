FROM gitlab/gitlab-ce:10.8.1-ce.0

#copy the default settings
COPY ["gitlab.rb.template", "/opt/gitlab/etc/"]
