# [PCF] Get GENE ID AND PAPER COUNT by MONDO ID NCBI GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0005093
  * example: 0009903, 0007943, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({ mondo_id }) =>
  'mondo:' + mondo_id.replace(/MONDO:/gi, '').trim().replace(/[\s,]+/g, ' mondo:');
```

## `get_mesh_id` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mondo: <http://purl.obolibrary.org/obo/MONDO_>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?mondo_list ?mesh_id
WHERE {
  VALUES ?mondo_list { {{mondo_id_list}} }
  #?mondo_sub_tier  rdfs:subClassOf* ?mondo_list .
  #?mondo_sub_tier skos:exactMatch ?mesh_id .
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
        obj[column] = (row[column] == null) ? "" : row[column].value;
      });
      return obj;
    });
    return mesh_list.map((row) => { return "<" + row["mesh_id"] + ">" }).join(" ");
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
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
SELECT DISTINCT ?gene_id ?count
WHERE {
  #GRAPH <http://purl.jp/bio/10/pubtator3/20240527>
  GRAPH <http://purl.jp/bio/10/rdfportal/20241227>
        {
          VALUES ?mesh_list { {{mesh_id_list}} }
          ?an rdf:type sio:SIO_000983 ;
              obo:RO_0003301 "ASSOCIATE" ;
              sio:SIO_000132 ?mesh_list ;
              sio:SIO_000132 ?ncbigene ;
              biolink:has_count ?count ;
              FILTER (CONTAINS(STR(?ncbigene), "http://identifiers.org/ncbigene/"))
              BIND(REPLACE(STR(?ncbigene), "http://identifiers.org/ncbigene/", "") AS ?gene_id)
        }
}
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