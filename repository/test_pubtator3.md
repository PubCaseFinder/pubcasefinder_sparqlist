# [PCF] Get PMID by MESH ID NCBI GENE ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mesh_id` MESH ID
  * default: C537680
  * example: C538184, D058747
* `ncbi_gene_id` NCBI gene ID
  * default: 1723
  * example: 10262, 55636
  
## Endpoint
http://plod01:7200/repositories/pubtator3

## `input` 
```sparql
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX mesh: <http://identifiers.org/mesh/>
PREFIX dcterms: <http://purl.org/dc/terms/>
SELECT DISTINCT ?pubmed_id
where {
  GRAPH <http://purl.jp/bio/10/pubtator3/20240527>
        {
          ?an sio:SIO_000132 ncbigene:{{ncbi_gene_id}} ;
        	  sio:SIO_000132 mesh:{{mesh_id}} ;
			  dcterms:source ?pubmed_id .
        }
}
```

## `pubmed_list`
```javascript
({
  json({input}) {
    let headers = input.head.vars;
    let pfam_list = input.results.bindings.map((row) => {
      let obj = {};
      headers.forEach((column) => {
        obj[column] = (row[column] == null) ? "" : row[column].value.replace('http://rdf.ncbi.nlm.nih.gov/pubmed/', '');
      });
      return obj;
    });
    return pfam_list.map((row) => { return "pubmed:" + row["pubmed_id"] }).join(" ");
  }
})
```
## Endpoint
https://rdfportal.org/ncbi/sparql

## `result` 
```sparql
PREFIX dcterm: <http://purl.org/dc/terms/>
PREFIX pubmed: <http://rdf.ncbi.nlm.nih.gov/pubmed/>
SELECT DISTINCT ?pmid ?date
{
  GRAPH <http://rdfportal.org/dataset/pubmed>
        {
          VALUES ?pubmed_id { {{pubmed_list}} }
          ?pubmed_id dcterm:created ?date ;
                     dcterm:identifier ?pmid .
        }
}
ORDER BY DESC(?date)
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