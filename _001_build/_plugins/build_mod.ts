/**
 * Created by Eastborn-PC on 07-06-17.
 */

/// <reference path="../../typings/index.d.ts" />

import * as fs from "fs";

import * as gulp from "gulp";
import * as gulpSequence from "gulp-sequence";
import * as gulpClean from "gulp-clean";
import * as gulpZip from "gulp-zip";

export default function (projectName, cb) {
    let factorioFolder = "../../"+fs.readdirSync("../../").filter(function(d) {return d.indexOf('Instance') > -1})[0];
    let version = JSON
        .parse(fs.readFileSync("../_010_mods/"+projectName+"/mod/info.json").toString())
        .version
        .split(".")
        .map(function(v) {return parseInt(v);})
        .join(".");
    let projectNameWithVersion = projectName+"_"+version;

    console.log(factorioFolder, version, projectName, projectNameWithVersion)

    gulp.task("gulp_plugin_build_mod_remove", () => {
        console.log("cleaning old mod");
        return gulp.src(factorioFolder+"/mods/"+projectName+"*.zip", {read:false})
            .pipe(gulpClean({force:true}));
    });

    gulp.task("gulp_plugin_build_mod_move", () => {
        console.log("moving mod");
        return gulp.src("../_010_mods/"+projectName+"/mod/**/*")
            .pipe(gulp.dest("tmp/"+projectNameWithVersion));
    });

    gulp.task("gulp_plugin_build_mod_move_lib", () => {
        console.log("moving lib");
        return gulp.src("../_010_mods/_EastModLib/mod/**/*")
            .pipe(gulp.dest("tmp/"+projectNameWithVersion));
    });

    gulp.task("gulp_plugin_build_mod_build", () => {
        console.log("zip mod");
        return gulp.src("tmp/**/*")
            .pipe(gulpZip(projectNameWithVersion+".zip"))
            .pipe(gulp.dest(factorioFolder+"/mods/"))
    });

    gulp.task("gulp_plugin_build_mod_clean", (cb) => {
        console.log("clean temp folder");
        return gulp.src("tmp/"+projectNameWithVersion+"/", {read:false})
            .pipe(gulpClean());
    });

    return gulpSequence(
        ["gulp_plugin_build_mod_remove", "gulp_plugin_build_mod_move", "gulp_plugin_build_mod_move_lib"],
        "gulp_plugin_build_mod_build",
        "gulp_plugin_build_mod_clean"
    )(cb);
}