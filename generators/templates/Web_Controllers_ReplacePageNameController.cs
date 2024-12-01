using Microsoft.AspNetCore.Mvc;

namespace ReplacePrefix.Controllers

[ApiController]
[Route("api/ReplacePageName")]
public class ReplacePageNameController : ControllerBase
{
    private readonly ReplacePageNameProcessor _processor;

    public ReplacePageNameController(ReplacePageNameProcessor processor) {
        _processor = processor;
    }
    
    [HttpGet]
    public Task<ReplacePageName> GetAsync() => _processor.GetAsync();

    [HttpPost]
    public Task<ReplacePageName> PostAsync([FromBody] ReplacePageNameForm form) => _processor.Save(form);
}