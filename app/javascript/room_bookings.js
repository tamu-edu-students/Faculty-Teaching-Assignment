document.addEventListener("turbo:load", function () {
    const tds = document.querySelectorAll(".grid-view-matrix td");
    
    tds.forEach((td) => {
      const table = td.closest("table");
      const colIndex = td.cellIndex;
      const cols = table.querySelectorAll(`td:nth-child(${colIndex + 1})`);
    
      td.addEventListener("mouseover", () => {
        cols.forEach((hover) => hover.classList.add("is-hover"));
      });
      td.addEventListener("mouseleave", () => {
        cols.forEach((hover) => hover.classList.remove("is-hover"));
      });
    });
})