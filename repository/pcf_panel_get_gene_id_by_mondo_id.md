# [PCF] Panel gene IDs by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: MONDO:0020341
  * accepts comma-separated MONDO IDs

## Endpoint
https://pubcasefinder.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g, "");
  return "mondo:MONDO_" + mondo_id.replace(/[\s,]+/g, " mondo:MONDO_");
}
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>

SELECT DISTINCT ?gene_id WHERE {
  VALUES ?mondo_list { {{mondo_id_list}} }
  ?disease rdfs:subClassOf* ?mondo_list .
  FILTER(STRSTARTS(STR(?disease), "http://purl.obolibrary.org/obo/MONDO_"))
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/pcf> {
    ?association sio:SIO_000628 ?disease ;
                 sio:SIO_000628 ?gene .
    ?gene rdf:type ncit:C16612 ;
          dcterms:identifier ?gene_id .
  }
}
```

## Output
```javascript
({mondo_id_list, result}) => {
  const values = result.results.bindings.map(row => "GENEID:" + row.gene_id.value);
  const key = mondo_id_list
    .replace(/mondo:MONDO_/gi, "MONDO:")
    .replace(/ /g, "|");
  return { [key]: values };
}
```
