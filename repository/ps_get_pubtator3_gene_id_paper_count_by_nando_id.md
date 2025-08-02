# [PCF] Get PubTator3 paper COUNT by NANDO ID NCBI GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200477
  * example: 1200478, 1200479, 1200480

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/g,"")
  nando_id = 'nando:NANDO_' + nando_id.replace(/[\s,]+/g," nando:NANDO_")
  return nando_id;
}
```

## `get_mesh_id` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX nando: <http://nanbyodata.jp/ontology/>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?mesh_id
WHERE {
  VALUES ?nando_list { {{nando_id_list}} }
  ?nando_list skos:exactMatch ?mondo_exactMatch .
  ?mondo_list rdfs:subClassOf* ?mondo_exactMatch .
  ?mondo_list skos:exactMatch ?mesh_id .
  FILTER(CONTAINS(STR(?mesh_id), "mesh"))
}
```

## `mesh_id_list`
```javascript
({
  json({get_mesh_id}) {
    let headers = get_mesh_id.head.vars;
    let mesh_list = get_mesh_id.results.bindings.map((row) => {
      let obj = {};
      headers.forEach((column) => {
        obj[column] = (row[column] == null) ? "" : row[column].value.replace('http://identifiers.org/mesh/', '');
      });
      return obj;
    });
    return mesh_list.map((row) => { return "mesh:" + row["mesh_id"] }).join(" ");
  }
})
```

## Endpoint
http://plod01:7200/repositories/PubTatorCentral

## `result` 
```sparql
#http://plod01:7200/repositories/pubtator3
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX mesh: <http://identifiers.org/mesh/>

SELECT DISTINCT ?gene_id (COUNT(DISTINCT ?pubmed_id) AS ?count)
WHERE {
  #GRAPH <http://purl.jp/bio/10/pubtator3/20240527>
  GRAPH <http://purl.jp/bio/10/rdfportal/20241227>
        {
          VALUES ?mesh_list { {{mesh_id_list}} }
          ?an rdf:type sio:SIO_000983 ;
              obo:RO_0003301 "ASSOCIATE" ;
              sio:SIO_000132 ?mesh_list ;
              sio:SIO_000132 ?ncbigene ;
              dcterms:source ?pubmed_id .
              #biolink:has_count ?count ;
              FILTER (CONTAINS(STR(?ncbigene), "http://identifiers.org/ncbigene/"))
              BIND(REPLACE(STR(?ncbigene), "http://identifiers.org/ncbigene/", "") AS ?gene_id)
        }
}
GROUP BY ?gene_id
```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}
```