<!-- Header block for project -->
<hr>

<div align="center">

![logo](https://user-images.githubusercontent.com/3129134/163255685-857aa780-880f-4c09-b08c-4b53bf4af54d.png)

<h1 align="center">Unity Example Application</h1>

</div>

<pre align="center">Example application illustrating structure for Unity App Generator application repositories</pre>

<!-- Header block for project -->

[unity-app-generator](https://github.com/unity-sds/unity-app-generator) | [app-pack-generator](https://github.com/unity-sds/app-pack-generator)

## Features

* Demonstrates Unity application structure
* Demonstrates Unity Jupyter notebook parameterization
* Demonstrates use of Unity-py for interacting with STAC files
  
## Requirements

* Python 3.9
* Jupyter
* Papermill
  
## Setup Instructions

Install required Python packages:

```
pip install -r requirements.txt
```

## Discussion

The `process.ipynb` notebook file is designed to work either as an independent notebook or as part of an OGC application package. It is meant for illustrative purposes and doesn't do any "real" work. What it does is show the parameterization of application arguments using Papermill and the use of Unity stage-in and stage-out mechanisms. The actions taken in the notebok are simply to extract some metadata from a set of netCDF files and place them into a textual table that is written out as well as displayed in the notebook.

### Parameters

Unity OGC applications rely upon using [Papermill parameritzation](https://papermill.readthedocs.io/en/latest/usage-parameterize.html) of arguments. One of the cells is tagged with the `parameters` tag, indicating to Papermill which cell to inspect for insertion of values from the command line. See the [app-pack-generator](https://github.com/unity-sds/app-pack-generator) for more information on the formatting of parameters and the use of type hints.

### stage-in

This notebook is connected to a Unity stage-in process through the `input_stac_collection_file` variable. This variable contains the location of a STAC feature collection file. That feature collection points to the input files used by the notebook. In our example notebook we use Unity-py to parse the file and obtain the full paths to the input files. 

### stage-out

In the example notebook `output_stac_catalog_dir` is the variable where the directory where a STAC catalog listing the output files should be placed. In the example we use Unity-py to create the output STAC catalog. The example gives the minimal amount of metadata necessary for writing a valid catalog file and corresponding item collection files.

## Testing

The `test/` directory contains some useful scripts for testing the example notebook with [unity-app-generator](https://github.com/unity-sds/unity-app-generator). It requires that package to be set up in your environment. 

The `test/ogc_app/build_app.sh` script will use unity-app-generator to build a Docker image and CWL files from the repository.

 The `test/ogc_app/test_cwl.sh` script can be used to test execution of the resulting CWL files. It requres that you first copy the `cwl_job_input.yml.template` file to be named `cwl_job_input.yml` in the same directory where it is located. Fill out the `edl_username` and `edl_password` values with base 64 encoded versions of your [Earthdata Login](https://urs.earthdata.nasa.gov/) credentials.

## Changelog

See our [CHANGELOG.md](CHANGELOG.md) for a history of our changes.

See our [releases page](https://github.com/unity-sds/unity-example-application/releases) for our key versioned releases.

## License

See our: [LICENSE](LICENSE.txt)