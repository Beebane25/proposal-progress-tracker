import { describe, expect, it } from 'vitest';
import { blockedBy, csvText, duplicates, percentage, validateBackup, cyclic } from './domain';

describe('proposal domain rules', () => {
  it('counts only verified completed work and handles empty projects', () => {
    expect(percentage([])).toBe(0);
    const tasks=[{id:'a',status:'Selesai',verifiedNote:'evidence',deps:[],weight:1,requireEvidence:true},{id:'b',status:'Belum Dimulai',verifiedNote:'',deps:[],weight:1,requireEvidence:true}];
    expect(percentage(tasks)).toBe(50);
  });
  it('blocks dependencies and detects circular dependencies', () => {
    const tasks=[{id:'a',status:'Belum Dimulai',deps:[]},{id:'b',status:'Belum Dimulai',deps:['a']}];
    expect(blockedBy(tasks[1],tasks)).toEqual(['a']);
    expect(cyclic([{id:'a',deps:['b']},{id:'b',deps:['a']}])).toBe(true);
  });
  it('detects duplicate DOI or URL', () => {
    expect(duplicates({doi:'https://doi.org/10.123/x'},{doi:'10.123/x'})).toBe(true);
    expect(duplicates({url:'https://example.test/a'},{url:'https://example.test/a'})).toBe(true);
  });
  it('escapes CSV cells and rejects unsafe/incomplete backups', () => {
    expect(csvText([['title','value'],['x','a,b']])).toContain('"a,b"');
    const valid={version:1,project:{title:'x',deadline:''},tasks:[],members:[],sources:[],chapters:[],policies:[],metrics:[]};
    expect(validateBackup(valid)).toBe(valid);
    expect(()=>validateBackup({...valid,tasks:[{id:'x',title:'',description:'',why:'',output:'',done:'',owner:'',section:'',priority:'Sedang',status:'Bad',due:'',deps:[],tags:[],verifiedNote:''}]})).toThrow();
  });
});
