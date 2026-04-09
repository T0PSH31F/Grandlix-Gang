const { performance } = require('perf_hooks');

const CATEGORIES_COUNT = 10;
const ITERATIONS = 1000000;

const categories = Array.from({ length: CATEGORIES_COUNT }, (_, i) => ({
  id: i === Math.floor(CATEGORIES_COUNT / 2) ? 'vegapunk' : `cat-${i}`,
  services: []
}));

function originalApproach() {
  const vegapunk = categories.find(c => c.id === 'vegapunk');
  const otherCategories = categories.filter(c => c.id !== 'vegapunk');
  return { vegapunk, otherCategories };
}

function optimizedApproachReduce() {
  return categories.reduce((acc, c) => {
    if (c.id === 'vegapunk') {
      acc.vegapunk = c;
    } else {
      acc.otherCategories.push(c);
    }
    return acc;
  }, { vegapunk: null, otherCategories: [] });
}

function runBenchmark(fn) {
  // Warmup
  for (let i = 0; i < 1000; i++) fn();

  const start = performance.now();
  for (let i = 0; i < ITERATIONS; i++) {
    fn();
  }
  const end = performance.now();
  return end - start;
}

console.log(`Benchmarking ${CATEGORIES_COUNT} categories over ${ITERATIONS} iterations...`);

const originalTime = runBenchmark(originalApproach);
const reduceTime = runBenchmark(optimizedApproachReduce);

console.log(`Original (find + filter): ${originalTime.toFixed(4)}ms`);
console.log(`Optimized (reduce): ${reduceTime.toFixed(4)}ms`);

const improvement = ((originalTime - reduceTime) / originalTime * 100).toFixed(2);
console.log(`Improvement (reduce vs original): ${improvement}%`);
