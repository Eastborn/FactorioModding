/**
 * Created by Eastborn-PC on 07-06-17.
 */

/// <reference path="../typings/index.d.ts" />

import * as gulp from "gulp";
import * as gulpSequence from "gulp-sequence";
import * as gulpUtil from "gulp-util";
import * as gulpWait from "gulp-wait";
import gulpBuildMod from "./_plugins/build_mod.js";

import * as childProcess from "child_process";
import * as fs from "fs";

let factorioFolder = "../../"+fs.readdirSync("../../").filter(function(d) {return d.indexOf('Instance') > -1})[0];

let argv = require('yargs')
    .option('project', {
        alias: "p",
        describe: "The project name",
        demandOption: true,
        type: "string",
        coerce: function(arg) {
            try {
                fs.accessSync("../_010_mods/"+arg+"/mod/info.json", fs.constants.R_OK | fs.constants.W_OK)
            } catch(e) {
                throw new Error("The file ["+arg+"] was not readable/writable or may not exist at all please run a map for more than 2 seconds after tab or create the file manually")
            }
            return arg;
        }
    })
    .help()
    .argv;

let projectName = argv.project;


gulp.task("build", (cb) => {
    console.log("Building mod");
    gulpBuildMod(projectName, cb);
});


gulp.task("run", (cb) => {
    console.log("Running Factorio");
    let factorio = childProcess.exec("\""+factorioFolder+"/bin/x64/factorio.exe"+"\" --load-game test1.zip", (err, stdout, stderr) => {
        console.log(stdout);
        console.log(stderr);
        (<any>cb)(err);
    });
});

gulp.task("exec", gulpSequence("build", "run"));