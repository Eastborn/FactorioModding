"use strict";
/**
 * Created by Eastborn-PC on 07-06-17.
 */
Object.defineProperty(exports, "__esModule", { value: true });
/// <reference path="../../typings/index.d.ts" />
var fs = require("fs");
var ChildProcess = require("child_process");
var gulp = require("gulp");
var gulpSequence = require("gulp-sequence");
var gulpClean = require("gulp-clean");
var gulpZip = require("gulp-zip");
function default_1(projectName, cb) {
    var factorioFolder = "../../" + fs.readdirSync("../../").filter(function (d) { return d.indexOf('Instance') > -1; })[0];
    var version = JSON
        .parse(fs.readFileSync("../_010_mods/" + projectName + "/mod/info.json").toString())
        .version
        .split(".")
        .map(function (v) { return parseInt(v); })
        .join(".");
    var projectNameWithVersion = projectName + "_" + version;
    console.log(factorioFolder, version, projectName, projectNameWithVersion);
    gulp.task("gulp_plugin_build_mod_remove", function () {
        console.log("cleaning old mod");
        return gulp.src(factorioFolder + "/mods/" + projectName + "*.zip", { read: false })
            .pipe(gulpClean({ force: true }));
    });
    gulp.task("gulp_plugin_build_mod_move", function () {
        console.log("moving mod");
        return gulp.src("../_010_mods/" + projectName + "/mod/**/*")
            .pipe(gulp.dest("tmp/" + projectNameWithVersion));
    });
    gulp.task("gulp_plugin_build_extract_move", function () {
        console.log("moving extract");
        return gulp.src("../_010_mods/" + projectName + "/mod_util/EXTRACT/**/*")
            .pipe(gulp.dest("tmp/" + projectNameWithVersion + "/EXTRACT"));
    });
    gulp.task("gulp_plugin_build_mod_move_lib", function () {
        console.log("moving lib");
        return gulp.src("../_010_mods/_EastModLib/mod/**/*")
            .pipe(gulp.dest("tmp/" + projectNameWithVersion));
    });
    gulp.task("gulp_plugin_build_mod_build", function () {
        console.log("zip mod");
        return gulp.src("tmp/**/*")
            .pipe(gulpZip(projectNameWithVersion + ".zip"))
            .pipe(gulp.dest(factorioFolder + "/mods/"));
    });
    gulp.task("gulp_plugin_build_mod_clean", function () {
        console.log("clean temp folder");
        return gulp.src("tmp/" + projectNameWithVersion + "/", { read: false })
            .pipe(gulpClean());
    });
    gulp.task("gulp_plugin_build_mod_create_exe_nodejs", function (cb) {
        if (projectName.indexOf("ChatToFile") > -1) {
            ChildProcess.exec("pkg \"../_010_mods/ChatToFile/mod_util/app/run.js\" --out-dir \"../_010_mods/ChatToFile/mod_util/exe/\"", function (error, stdout, stderr) {
                if (error) {
                    console.error("error packaging the app,", error);
                }
                else {
                    console.log("Created packaged app");
                }
                cb();
            });
        }
        else {
            cb();
        }
    });
    return gulpSequence(["gulp_plugin_build_mod_remove", "gulp_plugin_build_mod_move", "gulp_plugin_build_mod_move_lib", "gulp_plugin_build_mod_create_exe_nodejs", "gulp_plugin_build_extract_move"], "gulp_plugin_build_mod_build", "gulp_plugin_build_mod_clean")(cb);
}
exports.default = default_1;
