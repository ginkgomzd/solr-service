package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
)

// Command line flags

var cfgFlag = flag.String("c", "config.json", "Path to configuration json for target machine")

type Config struct {
	Configset_Name string
	DB_User        string
	DB_Password    string
	DB_CMS_DB      string
	Schema         string
	Solr_Host      string
	Solr_Port      uint32
}

func main() {

	// Command line usage stuff

	flag.Usage = func() {
		w := flag.CommandLine.Output()
		fmt.Fprint(w, "Using this build tool: \n")
		flag.PrintDefaults()
		fmt.Fprintf(w, "  -h or --help \n\tDisplays this help message :D\n")
	}
	flag.Parse()

	// Step 0: Specify src and dist directories

	dist_dir := "./dist"
	src_dir := "./src"

	// Step 1: Read "config.json" (or user specified json) into Config{}

	b, err := ioutil.ReadFile(*cfgFlag)
	if err != nil {
		log.Fatalf("Failed to read json file: %v", err)
	}

	cfg := Config{}

	err = json.Unmarshal(b, &cfg)
	if err != nil {
		log.Fatalf("Failed to parse json file: %v", err)
	}

	// Step 2: Clear dist directory and mkdir "dist/{{.Configset_Name}}/conf"

	err = os.RemoveAll(dist_dir)
	if err != nil {
		log.Fatalf("failed to delete dist folder (try deleting manually): %v", err)
	}

	err = os.MkdirAll(dist_dir+"/"+cfg.Configset_Name+"/conf", 0755)
	if err != nil {
		log.Fatalf("failed to create dist folder: %v", err)
	}

	//	Step 3: Generate db-data-config.xml from template and write to file

	// Parse template file
	tpl, err := template.ParseFiles(src_dir + "/template/db-data-config.tpl")
	if err != nil {
		log.Fatalf("failed parsing file template: %v", err)
	}

	// Read data schema and include in our cfg
	schema, err := ioutil.ReadFile(src_dir + "/template/db-data-config-schema.xml")
	if err != nil {
		log.Fatalf("failed to read data config schema: %v", err)
	}

	cfg.Schema = string(schema)

	// Create db-data-config.xml for writing
	out, err := os.Create(dist_dir + "/" + cfg.Configset_Name + "/conf/db-data-config.xml")
	if err != nil {
		log.Fatalf("failed to create db-data-config.xml in dist folder: %v", err)
	}
	defer out.Close()

	// Write to db-data-config.xml and close the file
	err = tpl.Execute(out, cfg)
	if err != nil {
		log.Fatalf("failed to execute template: %v", err)
	}

	// 	Step 4: Copy static configuration files over. Using recursive copy in shell for bevity

	cp := exec.Command("cp", "-r", src_dir+"/static/", "dist/"+cfg.Configset_Name+"/conf")
	err = cp.Run()
	if err != nil {
		log.Fatalf("failed to copy static config files: %v", err)
	}
}
