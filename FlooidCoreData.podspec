Pod::Spec.new do |s|

s.name         = "FlooidCoreData"
s.version      = "0.0.27"
s.summary      = "Core Data stack helper."
s.description  = "Core Data stack helper."
s.homepage     = "http://github.com/martin-lalev/FlooidCoreData"
s.license      = "MIT"
s.author       = "Martin Lalev"
s.platform     = :ios, "10.0"
s.source       = { :git => "https://github.com/martin-lalev/FlooidCoreData.git", :tag => s.version }
s.source_files  = "FlooidCoreData", "FlooidCoreData/**/*.{swift}"
s.swift_version = '5.0'

end
