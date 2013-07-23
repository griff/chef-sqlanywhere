# chef-sqlanywhere

## Description

Installs and configures SQLAnywhere

Several lightweight resources and providers ([LWRP][lwrp]) are also defined.

## Usage

## Requirements

### Chef

Tested on 0.10.4 but newer versions should work just fine.

File an [issue][issues] if this isn't the case.

### Platform

The following platforms have been tested with this cookbook, meaning that
the recipes and LWRPs run on these platforms without error:

* ubuntu (10.04/10.10/11.04)

Please [report][issues] any additional platforms so they can be added.

### Cookbooks

There are **no** external cookbook dependencies.

## Installation

Depending on the situation and use case there are several ways to install
this cookbook. All the methods listed below assume a tagged version release
is the target, but omit the tags to get the head of development. A valid
Chef repository structure like the [Opscode repo][chef_repo] is also assumed.

### Using Librarian-Chef

[Librarian-Chef][librarian] is a bundler for your Chef cookbooks.
Include a reference to the cookbook in a [Cheffile][cheffile] and run
`librarian-chef install`. To install Librarian-Chef:

    gem install librarian
    cd chef-repo
    librarian-chef init
    cat >> Cheffile <<END_OF_CHEFFILE
    cookbook 'rvm',
      :git => 'git://github.com/griff/chef-sqlanywhere.git', :ref => 'v1.0.0'
    END_OF_CHEFFILE
    librarian-chef install

### Using knife-github-cookbooks

The [knife-github-cookbooks][kgc] gem is a plugin for *knife* that supports
installing cookbooks directly from a GitHub repository. To install with the
plugin:

    gem install knife-github-cookbooks
    cd chef-repo
    knife cookbook github install griff/chef-sqlanywhere/v1.0.0

### As a Git Submodule

A common practice (which is getting dated) is to add cookbooks as Git
submodules. This is accomplishes like so:

    cd chef-repo
    git submodule add git://github.com/griff/chef-sqlanywhere.git cookbooks/sqlanywhere
    git submodule init && git submodule update

**Note:** the head of development will be linked here, not a tagged release.

### As a Tarball

If the cookbook needs to downloaded temporarily just to be uploaded to a Chef
Server or Opscode Hosted Chef, then a tarball installation might fit the bill:

    cd chef-repo/cookbooks
    curl -Ls https://github.com/griff/chef-sqlanywhere/tarball/v1.0.0 | tar xfz - && \
      mv griff-chef-sqlanywhere-* sqlanywhere

### From the Opscode Community Platform

This cookbook is not currently available on the site due to the flat
namespace for cookbooks. There is some community work to be done here.

## Recipes

### default

### server

## Attributes

### key

The your license key to use for the installation.
**This is required and you must provide it for the installation to work**

### url

URL where the installation bundle can be downloaded from.
**This is required and you must provide it for the installation to work**

### install_dir

The default is `"/usr/local/sqlanywhere12"`.

### data_dir

The default is `"/var/local/sqlanywhere12"`.

### packages

The default is `['sqlany32', 'admintools', 'samon', 'in_memory']`.

### patch\_for_silent

The default is `false`.

### server_name

    node['sqlanywhere']['server_name'] = 'sample'

The default is `"default"`.

### server\_utility_password

DBA password for the utility database. Also used as the dba password for new databases.

    node['sqlanywhere']['server_utility_password'] = 'sql'

The default is to generate a secure random password and setting the attribute on the node.


## Resources and Providers

### sqlanywhere_database

#### Actions

<table>
  <thead>
    <tr>
      <th>Action</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>create</td>
      <td>
        Create the named database.
      </td>
    </tr>
    <tr>
      <td>drop</td>
      <td>
        Remove the named database.
      </td>
    </tr>
    <tr>
      <td>query</td>
      <td>
        Perform a query against the database
      </td>
    </tr>
    <tr>
      <td>query_file</td>
      <td>
        Perform a query loaded from file against the database
      </td>
    </tr>
  </tbody>
</table>

#### Attributes

### sqlanywhere\_database_user

####Actions

#### Attributes

## Chef Solo Note

The following node attribute is stored on the Chef Server when using
`chef-client`. Because `chef-solo` does not connect to a server or
save the node object at all, to have the password persist across
`chef-solo` runs, you must specify them in the `json_attribs` file
used. For Example:

    {
      "sqlanywhere": {
          "server_utility_password": "iloverandompasswordsbutthiswilldo"
      },
      "run_list": ["recipe[sqlanywhere::server]"]
    }

## Development

* Source hosted at [GitHub][repo]
* Report issues/Questions/Feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every seperate change you make.


## License & Author

Author:: [Brian Olsen][griff] (<brian@maven-group.org>) [![endorse](http://api.coderwall.com/griff/endorsecount.png)](http://coderwall.com/griff)


Contributors:: https://github.com/griff/chef-sqlanywhere/contributors

Copyright:: 2012, Brian Olsen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[griff]:                https://github.com/griff
[lwrp]:                 http://wiki.opscode.com/display/chef/Lightweight+Resources+and+Providers+%28LWRP%29

[repo]:         https://github.com/griff/chef-sqlanywhere
[issues]:       https://github.com/griff/chef-sqlanywhere/issues