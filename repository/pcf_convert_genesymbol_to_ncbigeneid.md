# pcf_convert_genesymbol_to_ncbigeneid
## Parameters
* `hgnc_gene_symbol`
  * default: POLG SLC7A7 CBS
  * example: POLG SLC7A7 CBS

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hgnc_gene_symbol_list`
```javascript
({hgnc_gene_symbol}) => {
/*
  //hgnc_gene_symbol = '\"' + hgnc_gene_symbol.replace(/[\s,]+/g,"\" \"") + '\"'
  //return hgnc_gene_symbol;
*/  
/*  
  const symbols = hgnc_gene_symbol.split(' ');
  const uniq = [...new Set(symbols)];
  const values = uniq.map(x => `"${x}"`).join(' ');
  return values;
*/
/*
  if (hgnc_gene_symbol.match(/[^\s]/)) return hgnc_gene_symbol.split(/\s+/);
  return false;
*/
  const symbols = hgnc_gene_symbol.replace(/[\s,]+/g," ").split(' ');
  const uniq = [...new Set(symbols)];
  return uniq;
}
```

## `result`
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>

SELECT DISTINCT
?hgnc_gene_symbol
?ncbi_gene_id
WHERE {
  #VALUES ?hgnc_gene_symbol { {{hgnc_gene_symbol_list}} }
  VALUES ?hgnc_gene_symbol { {{#each hgnc_gene_symbol_list}} "{{this}}" {{/each}} }

  ?ncbi_gene_url sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] ;
                 dcterms:identifier ?ncbi_gene_id .
  
  #?HGNC_id rdfs:label ?hgnc_gene_symbol .
  #?ncbi_gene_url rdf:type ncit:C16612 .
  #?ncbi_gene_url sio:SIO_000205 ?HGNC_id ;
  #               dcterms:identifier ?ncbi_gene_id .
  
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