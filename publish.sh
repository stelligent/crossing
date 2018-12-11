#!/bin/bash -ex
set -o pipefail

#
# Set the current major and minor version
# 0.1.x
#
major_version='0'
minor_version='2'

#
# Set the API key gem credentials
#
mkdir -p ~/.gem
set +x
if [[ -z ${rubygems_api_key} ]];
then
  echo "rubygems_api_key must be set in the environment"
  exit 1
fi
set -x

set +ex
echo :rubygems_api_key: ${rubygems_api_key} > ~/.gem/credentials
set -ex
chmod 0600 ~/.gem/credentials

git config --global user.email "build@build.com"
git config --global user.name "build"

#
# Pull current version number from the git tags
#
current_version=$(ruby -e 'tags=`git tag -l v'$major_version'\.'$minor_version'\.*`' \
                       -e 'p tags.lines.map { |tag| tag.sub(/v'$major_version'.'$minor_version'./, "").chomp.to_i }.max')


#
# Increment the version number, update the gemspect and add version tag to git
#
if [[ ${current_version} == nil ]];
then
  new_version=$major_version.$minor_version.0
else
  new_version=$major_version.$minor_version.$((current_version+1))
fi

sed -i "s/0\.0\.0/${new_version}/g" crossing.gemspec

git tag -a v${new_version} -m "${new_version}"

#
# Build gem then check CIRCLE_BRANCH is master before pushing
#
gem build crossing.gemspec

if [[ ${CIRCLE_BRANCH} == "master" ]];
        then
                echo "Pushing gem from master!"
                gem push crossing-*.gem
                git push --tags
                exit 0
        else
                echo "Not in master, skipping gem push!"
                exit 0
fi
