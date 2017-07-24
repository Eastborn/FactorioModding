"use strict";
/**
 * Created by Eastborn-PC on 07-06-17.
 */
Object.defineProperty(exports, "__esModule", { value: true });
/// <reference path="../typings/index.d.ts" />
var gulp = require("gulp");
var gulpSequence = require("gulp-sequence");
var build_mod_js_1 = require("./_plugins/build_mod.js");
var childProcess = require("child_process");
var fs = require("fs");
var factorioFolder = "../../" + fs.readdirSync("../../").filter(function (d) { return d.indexOf('Instance') > -1; })[0];
var argv = require('yargs')
    .option('project', {
    alias: "p",
    describe: "The project name",
    demandOption: true,
    type: "string",
    coerce: function (arg) {
        try {
            fs.accessSync("../_010_mods/" + arg + "/mod/info.json", fs.constants.R_OK | fs.constants.W_OK);
        }
        catch (e) {
            throw new Error("The file [" + arg + "] was not readable/writable or may not exist at all please run a map for more than 2 seconds after tab or create the file manually");
        }
        return arg;
    }
})
    .help()
    .argv;
var projectName = argv.project;
gulp.task("build", function (cb) {
    console.log("Building mod");
    build_mod_js_1.default(projectName, cb);
});
gulp.task("run", function (cb) {
    console.log("Running Factorio");
    var factorio = childProcess.exec("\"" + factorioFolder + "/bin/x64/factorio.exe" + "\" --load-game test1.zip", function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
});
gulp.task("exec", gulpSequence("build", "run"));
