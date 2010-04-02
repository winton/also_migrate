GemTemplate
===========

A gem template for new projects.

Requirements
------------

<pre>
sudo gem install stencil
</pre>

Setup the template
------------------

You only have to do this once.

<pre>
git clone git@github.com:winton/migrate_with.git
cd migrate_with
stencil
</pre>

Setup a new project
-------------------

Do this for every new project.

<pre>
mkdir my_project
git init
stencil migrate_with
rake rename
</pre>

The last command does a find-replace (gem\_template -> my\_project) on files and filenames.
