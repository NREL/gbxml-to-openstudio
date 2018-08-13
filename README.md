# gbxml-to-openstudio
This repository is intended to develop code that uses one or more advanced gbXML import measures to take gbXML to OSM translation beyond what is covered by GbXMLReverseTranslator in the OpenStudio C++ code.
 
 The initial commit includes the following directories.
 * gbxmls - example gbXML files
 * measures - existing and new measures used to translate and test gbXML to OSM translation
 * workflows - OSW files that using the OpenStudio CLI run the gbXML to OSM translation workflow measures, forward translate OSM to IDF, and run EnergyPlus
 * seeds - contains seed models used by one or more OSW files
 * weather - contain one or more weather files used by OSW files