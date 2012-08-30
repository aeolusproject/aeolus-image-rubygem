[![Build
Status](https://secure.travis-ci.org/aeolusproject/aeolus-image-rubygem.png)](http://travis-ci.org/aeolusproject/aeolus-image-rubygem)

# aeolus-image-rubygem #
**aeolus-image-rubygem** is a Ruby library used by [Conductor](https://github.com/aeolusproject/conductor) to connect with Image Factory and Image Warehouse.

It provides a gem named **aeolus-image**, which shouldn't be confused with the [aeolus-image](https://github.com/aeolusproject/aeolus-image) command-line tool. (There's talk of renaming these shortly to alleviate this confusion.)

## Configuration ##
aeolus-image-rubygem is meant to be leveraged in code. You might check out [config/initializers/aeolus-image.rb](https://github.com/aeolusproject/conductor/blob/master/src/config/initializers/aeolus-image.rb) in Conductor for an example.

## Usage ##
After configurating Factory and/or Warehouse hosts, you can do things like the following:

### Warehouse ###

~~~
   images = Aeolus::Image::Warehouse::Image.all
   
   image1 = images.first
   image1.name # => ""
   image1.image_builds # => an array of ImageBuild objects
~~~

### Factory ###

~~~
   builds_in_progress = Aeolus::Image::Factory::Builder.all
~~~

#### Start a build with Factory ####

~~~
   img = Aeolus::Image::Factory::Image.new(
    :targets => 'ec2',
    :template => IO.read('/home/mawagner/template.tpl')
   )
   img.save!
~~~
