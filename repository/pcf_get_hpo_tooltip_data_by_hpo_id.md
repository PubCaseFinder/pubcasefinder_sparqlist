# [PCF] Get HPO tooltip data by HPO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0000347
  * example: 0410219, 0031815, 0040184

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => {
  hpo_id = hpo_id.replace(/HP:/g,"")
  return hpo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT DISTINCT
str(?name_en) as ?name_en
str(?name_ja) as ?name_ja
str(?definition) as ?definition
str(?comment) as ?comment
str(?synonym) as ?synonym
str(?hpo_url) as ?hpo_url

WHERE { 
    VALUES ?hp_id { obo:HP_{{hpo_id_list}} }

    GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
      optional { ?hp_id rdfs:label ?name_en . }
      optional { ?hp_id obo:IAO_0000115 ?definition . }
      optional { ?hp_id <http://www.geneontology.org/formats/oboInOwl#hasExactSynonym> ?synonym . }
      optional { ?hp_id rdfs:comment ?comment . }
    }
    
    optional { ?hp_id rdfs:seeAlso ?hpo_url . }
    optional { ?hp_id rdfs:label ?name_ja . FILTER (lang(?name_ja) = "ja") }

} order by ?hpo_url ?synonym
```

## Output
```javascript
({ result }) => {
  const rows = result.results.bindings;
  const dic = {
    name_en: "",
    name_ja: "",
    definition: "",
    comment: "",
    hpo_url: "",
    synonym: []
  }
  rows.forEach(row => {
    Object.keys(dic).forEach(k => {
      const val = row[k].value
      if (Array.isArray(dic[k]) && !dic[k].includes(val)) {
        dic[k] = [...dic[k], val]
        return
      }
      if (typeof dic[k] === "string") {
        dic[k] = val
      }
    })
  })
  return dic
}
```