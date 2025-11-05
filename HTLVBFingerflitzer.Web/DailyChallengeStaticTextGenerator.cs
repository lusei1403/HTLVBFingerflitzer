class DailyChallengeStaticTextGenerator : IDailyChallengeTextGenerator
{
    public string StaticText { get; }

    public DailyChallengeStaticTextGenerator(string staticText)
    {
        StaticText = staticText;
    }

    public Task<string> GetDailyChallengeTextAsync()
    {
        return Task.FromResult(StaticText);
    }
}

class DailyChallengeRotatingTextGenerator : IDailyChallengeTextGenerator
{
    private int textIndex = 0;
    public string[] Texts { get; }

    public DailyChallengeRotatingTextGenerator(string[] texts)
    {
        Texts = texts;
    }

    public Task<string> GetDailyChallengeTextAsync()
    {
        return Task.FromResult(Texts[textIndex++ % Texts.Length]);
    }
}