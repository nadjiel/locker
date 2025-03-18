import * as fs from 'node:fs';
import path from "node:path";

import {
  ADDON_PATH,
  PLUGIN_PATH,
  README_PATH,
  LICENSE_PATH,
  getPackageJson,
  getPluginCfg,
  getPluginField,
  setPluginField,
} from "./consts.js";

function updatePluginCfg(pluginCfg, newVersion) {
  const updatedPluginCfg = setPluginField(pluginCfg, "version", newVersion);
  
  fs.writeFileSync(PLUGIN_PATH, updatedPluginCfg);
}

function updateAddonFiles() {
  [ README_PATH, LICENSE_PATH ].forEach(filePath => {
    if(!fs.existsSync(filePath)) {
      return;
    }
    
    const fileName = filePath.split(path.sep).pop();

    fs.cpSync(filePath, path.join(ADDON_PATH, fileName));

    console.log(`Updated ${path.join(ADDON_PATH, fileName)}`);
  });
}

function main() {
  const packageJson = getPackageJson();
  const pluginCfg = getPluginCfg();
  
  const packageVersion = packageJson?.version;
  
  if(!packageVersion) {
    throw new Error("No version set in package.json");
  }
  
  const pluginVersion = getPluginField(pluginCfg, "version");
  
  if(packageVersion === pluginVersion) {
    console.log(`Plugin already updated with version: ${packageVersion}`);
    return;
  }
  
  updatePluginCfg(pluginCfg, packageVersion);
  
  console.log(`Updated plugin.cfg version: ${packageVersion}`)
  
  updateAddonFiles();
}

main();
