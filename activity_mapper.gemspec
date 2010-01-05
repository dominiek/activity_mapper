# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = "activity_mapper"
  s.version = "0.1.0"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["dominiek"]
  s.date = "2010-01-05"
  s.description = "A framework for aggregating (public) social activity into a single polymorphic persistent structure."
  s.email = "info@dominiek.com"
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["README.textile"] + Dir.glob("{spec,lib}/**/*")
  s.homepage = "http://github.com/dominiek/activity_mapper"
  s.rdoc_options = ["--title", "Activity Mapper", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.textile", "--inline-source", "--exclude", "^(examples)/"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.5"
  s.summary = s.description
  s.test_files = Dir.glob("{spec}/**/*")
end
