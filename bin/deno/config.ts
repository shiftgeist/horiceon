import { parse as yamlParse } from 'https://deno.land/std@0.173.0/encoding/yaml.ts'

const riceConfigDir = Deno.env.get('XDG_CONFIG_HOME')
const riceConfig = await Deno.readTextFile(
  `${riceConfigDir}/chezmoi/chezmoi.yaml`
)
const configParsed = yamlParse(riceConfig)

export default configParsed
