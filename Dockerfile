FROM gitlab/gitlab-ce:10.8.1-ce.0

COPY ["gitlab.rb", "/etc/gitlab/"]
